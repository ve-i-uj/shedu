"""Распечатывает в stdout имя переменной окружения в конфиге и документацию к ней.

Данные берутся из `configs/example.env`.
"""

from pathlib import Path

_ENV_EXAMPLE_PATH= Path(__file__).parent.parent.parent / 'configs' / 'example.env'


def main():
    res_lines = {}

    with _ENV_EXAMPLE_PATH.open() as fh:
        lines = fh.readlines()

    var_name = ''
    doc_lines = []
    for line in lines:
        if not line.strip():
            continue
        if line.startswith('#'):
            doc_lines.append(line.strip('#').strip('').strip('\n'))
            continue
        var_name = line.split('=')[0].strip()
        res_lines[var_name] = doc_lines

        doc_lines = []
        var_name = ''

    print()
    for var_name, doc_lines in res_lines.items():
        var_doc_text = var_name + '\n'
        var_doc_text += '\n'.join(f'    {doc_line}' for doc_line in doc_lines)
        print(var_doc_text + '\n')



if __name__ == '__main__':
    main()
