import collections
import copy
import json
import math
import re
import shutil
import subprocess
import sys
from pathlib import Path

root = Path(sys.argv[1])
out = root / 'rebased-ready'
idx_name = 'scenario_info.psb.m'
body_name = 'scenario_body.bin'
counts = collections.Counter()


def read(p):
    return json.loads(p.read_text(encoding='utf-8-sig'))


def write(p, obj):
    p.write_text(json.dumps(obj, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')


def rows(doc):
    if 'en' not in doc.get('languages', []):
        return {}
    en_index = doc['languages'].index('en') + 1
    result = {}
    for scene in doc.get('scenes', []):
        for i, row in enumerate(scene.get('texts', [])):
            slots = row[1]
            if not slots or len(slots) <= en_index or not isinstance(slots[en_index], list):
                continue
            jp, en = slots[0], slots[en_index]
            if len(jp) < 3 or len(en) < 3 or not isinstance(en[1], str):
                continue
            voice = row[2] if len(row) > 2 and isinstance(row[2], list) else []
            voice_ids = tuple(v['voice'] for v in voice if isinstance(v, dict) and v.get('voice'))
            loc = (scene['label'], i)
            assert loc not in result
            result[loc] = ((tuple(jp[:2]), voice_ids), en)
    return result


def identity(jp_voice, en):
    return jp_voice, re.sub(r'[^\w]+', '', en[1]).casefold(), len(en)


def run(tool, args, cwd):
    p = subprocess.run([str(root / 'tools' / (tool + '.exe')), *args], cwd=cwd,
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                       creationflags=subprocess.CREATE_NO_WINDOW, check=False)
    log = p.stdout.decode('utf-8', errors='replace')
    if p.returncode or '[ERROR]' in log:
        raise RuntimeError(log)
    return log


def read_bundle(version):
    base = root / version
    return read(base / (idx_name + '.json')), (base / body_name).read_bytes()


def payload(bundle, key):
    index, body = bundle
    start, size = index['file_info'][key]
    blob = body[start:start + size]
    assert len(blob) == size and blob[:4] == b'mzs\0', (key, blob[:4])
    return blob


def localized(repl, new_text):
    assert len(repl) == 3, repl
    n = len(new_text.encode('utf-16-le')) // 2
    return (repl[0], new_text, n)


# French edits for dialogue changed by the October update.
corrections = {
    ('resg01_05.ks', '*start', 38): '« Cependant, toutes ces théories restent de pures hypothèses. »',
    ('resg01_05.ks', '*start', 40): "« Eh bien, et si quelqu'un proposait une douzième théorie ? »",
    ('resg01_05.ks', '*start', 42): '« Une treizième théorie pourrait la contredire, non ? »',
    ('resg02_17.ks', '*dummy23', 0): '« Il y a shoyu et shio. »',
    ('resg02_17.ks', '*dummy23', 1): '« Shio. »',
    ('resg03_13.ks', '*accept_2', 8): '« Hé. »',
    ('resg05_04.ks', '*start', 19): "« ...J'imagine. »",
    ('resg05_10.ks', '*start', 22): '« Alors moi, Hououin Kyouma, je déciderai si cela passe avant le développement de la time leap machine ! »',
    ('resg05_17.ks', '*start', 157): "Je profite de l'écran de fumée pour courir moi aussi vers la salle de développement.",
    ('resg05_17.ks', '*start', 158): 'Kurisu se tient devant la time leap machine.',
    ('resg06_18.ks', '*011', 17): "« OK. Je t'attends. »",
    ('resg06_18.ks', '*011', 24): "« Je me suis dit que tu avais sans doute oublié, Okabe, alors je voulais m'en assurer. »",
    ('resg06_24s.ks', '*from_resg06_23', 192): '« Assassiner. Voler. Kidnapper. Mentir. Détruire. »',
    ('resg07_09.ks', '*start', 37): '« Tu aurais pu simplement remonter le temps, mais tu as risqué ta vie pour me sauver. »',
    ('resg10_12k.ks', '*ending', 4): "À l'instar du savant fou Hououin Kyouma, seigneur de l'espace-temps...",
    ('resg10_12k.ks', '*ending', 5): "Il est temps que le téléphone micro-ondes (nom provisoire) soit condamné à mort.",
}


def make(scan=False):
    source_meta = root / 'current' / (idx_name + '.resx.json')
    if not scan:
        out.mkdir()
        shutil.copy2(source_meta, out)
    meta = read(source_meta)
    assert not meta['Context']['ArchiveItemFileNames']
    old, new, fr = (read_bundle(v) for v in ('old', 'current', 'fr'))
    assert set(old[0]['file_info']) == set(fr[0]['file_info'])
    assert new[0]['expire_suffix_list'] == old[0]['expire_suffix_list'] == ['.scn.m']
    lookup = collections.defaultdict(set)
    prior = {}
    for key in old[0]['file_info']:
        name = key + '.scn.m.json'
        old_rows = rows(read(root / 'old' / 'scenario' / name))
        mod_rows = rows(read(root / 'fr' / 'scenario' / name))
        assert old_rows.keys() == mod_rows.keys(), key
        prior[key] = {}
        for loc, (jp_voice, en) in old_rows.items():
            fr_id, repl = mod_rows[loc]
            assert jp_voice == fr_id, (key, loc)
            assert len(en) == len(repl), (key, loc)
            ident = identity(jp_voice, en)
            prior[key][loc] = (ident, tuple(en), tuple(repl))
            lookup[ident].add(tuple(repl))

    index = copy.deepcopy(new[0])
    plan = {}
    used_corrections = set()
    scene_dir = out / 'scenes'
    if not scan:
        scene_dir.mkdir()
    import os
    with (Path(os.devnull) if scan else out / body_name).open('wb') as body:
        for key, _ in sorted(new[0]['file_info'].items(), key=lambda x: x[1][0]):
            name = key + '.scn.m'
            cur_psb = root / 'current' / 'scenario' / name
            old_psb = root / 'old' / 'scenario' / name
            if old_psb.is_file() and old_psb.read_bytes() == cur_psb.read_bytes():
                blob = payload(fr, key)
                plan[key] = 'fr'
            else:
                doc = read(cur_psb.with_name(name + '.json'))
                altered = 0
                for loc, (jp_voice, en) in rows(doc).items():
                    ident = identity(jp_voice, en)
                    prev = prior.get(key, {}).get(loc)
                    fix = (key, *loc)
                    if fix in corrections:
                        assert prev and prev[0][0] == jp_voice and prev[0] != ident
                        repl = localized(prev[2], corrections[fix])
                        used_corrections.add(fix)
                        counts['updated translation'] += 1
                    elif prev and prev[0] == ident:
                        repl = prev[2]
                    elif key == 'resg01_08.ks' and loc == ('*start', 47):
                        # Steam removed an inline progress directive from JP only.
                        assert prev and prev[1] == tuple(en)
                        assert prev[0][0][0][1].endswith(jp_voice[0][1])
                        repl = prev[2]
                    elif len(lookup[ident]) == 1:
                        repl = next(iter(lookup[ident]))
                    elif prev and prev[0][0] == jp_voice and len(prev[2]) == len(en):
                        repl = prev[2]
                        counts['retained on reworded EN'] += 1
                    else:
                        if scan:
                            print('unmatched', key, loc, repr(en), 'jp/voice:', jp_voice, 'prior:', prev, flush=True)
                            counts['unmatched'] += 1
                            continue
                        raise ValueError(f'unmatched text in {key} {loc}: {en[1]!r}')
                    if tuple(en) != repl:
                        en[:] = repl
                        altered += 1
                if altered and not scan:
                    counts['reapplied rows'] += altered
                    scene_meta = read(cur_psb.with_name(name + '.resx.json'))
                    assert not scene_meta['Resources'], key
                    scene_meta['Context'] = {k: meta['Context'][k] for k in ('PsbShellType', 'MdfKeyLength')}
                    scene_meta['Context']['FileName'] = name
                    scene_meta['Context']['MdfKey'] = meta['Context']['MdfMtKey'] + name
                    write(scene_dir / (name + '.resx.json'), scene_meta)
                    write(scene_dir / (name + '.json'), doc)
                    run('PsBuild', ['-O0', '-o', name, name + '.json'], scene_dir)
                    blob = (scene_dir / name).read_bytes()
                    assert blob[:4] == b'mzs\0', key
                    plan[key] = 'rebuilt'
                else:
                    blob = payload(new, key)
                    plan[key] = 'current'
            counts[plan[key]] += 1
            if not scan:
                index['file_info'][key] = [body.tell(), len(blob)]
                body.write(blob)

    assert used_corrections == corrections.keys(), corrections.keys() - used_corrections
    if scan:
        print(dict(counts), flush=True)
        return
    write(out / 'plan.json', plan)
    write(out / (idx_name + '.json'), index)
    run('PsBuild', ['-o', idx_name, idx_name + '.json'], out)
    assert (out / idx_name).read_bytes()[:4] == b'mzs\0'
    print(dict(counts), flush=True)


def verify():
    folder = root / 'verified-final'
    folder.mkdir()
    for n in (idx_name, body_name):
        shutil.copy2(out / n, folder)
    meta = read(out / (idx_name + '.resx.json'))['Context']
    plan = read(out / 'plan.json')
    log = run('PsbDecompile', ['info-psb', '-k', meta['MdfMtKey'], '-l', str(meta['MdfKeyLength']), idx_name], folder)
    assert f'{len(plan)}/{len(plan)} files extracted; 0 failed.' in log, log
    assert read(folder / (idx_name + '.json')) == read(out / (idx_name + '.json'))
    scene = folder / 'scenario'
    rebuilt = [key + '.scn.m' for key, mode in plan.items() if mode == 'rebuilt']
    run('PsbDecompile', ['-raw', *rebuilt], scene)
    def same_tree(a, b):
        if type(a) is not type(b):
            return False
        if isinstance(a, dict):
            return a.keys() == b.keys() and all(same_tree(a[k], b[k]) for k in a)
        if isinstance(a, list):
            return len(a) == len(b) and all(same_tree(x, y) for x, y in zip(a, b))
        if isinstance(a, float):
            # FreeMote uses float32 where permitted when recompiling a scene.
            return math.isclose(a, b, rel_tol=1.2e-7, abs_tol=1e-9)
        return a == b

    for key, mode in plan.items():
        name = key + '.scn.m'
        if mode == 'rebuilt':
            n = name + '.json'
            assert same_tree(read(scene / n), read(out / 'scenes' / n)), key
        else:
            assert (scene / name).read_bytes() == (root / mode / 'scenario' / name).read_bytes(), key
    print(f'Verified index and all {len(plan)} entries; {len(rebuilt)} compiled scene trees match except for float32 rounding.', flush=True)


if sys.argv[2] == 'make':
    make()
elif sys.argv[2] == 'scan':
    make(scan=True)
elif sys.argv[2] == 'verify':
    verify()
else:
    raise ValueError(sys.argv[2])
