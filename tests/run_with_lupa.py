import os
from pathlib import Path
from lupa.lua54 import LuaRuntime

root = Path(__file__).resolve().parents[1]
os.chdir(root)
lua = LuaRuntime(unpack_returned_tuples=True)
for source in root.rglob('*.lua'):
    result = lua.eval('load')(source.read_text(encoding='utf-8-sig'), str(source))
    if isinstance(result, tuple):
        raise RuntimeError(result[1])
lua.execute((root / 'tests' / 'run.lua').read_text(encoding='utf-8-sig'))
