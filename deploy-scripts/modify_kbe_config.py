"""The script modifies the kbengine.xml configuration file so KBEngine can work with docker.

It would be placed in the root directory of the assets.
"""

import os
import xml.etree.ElementTree as ET

HOST_ADDR = '0.0.0.0'

MYSQL_DATABASE = os.environ['MYSQL_DATABASE']
MYSQL_USER = os.environ['MYSQL_USER']
MYSQL_PASSWORD = os.environ['MYSQL_PASSWORD']

# TODO: [30.07.2022 burov_alexey@mail.ru]:
# 1. Общий перехватчик ошибки?
# 2. Запиусть под дебагом
# 3. Смотреть под дебагом xml, которую удаляю




def main():
    curr_dir = os.path.dirname(__file__)
    conf_path = os.path.join(curr_dir, 'res', 'server', 'kbengine.xml')
    # TODO: [26.10.2021 burov_alexey@mail.ru]:
    # Проверка, что путь существует иначе запись в лог и выход с ошибкой (exit 1)
    tree = ET.parse(conf_path)
    root = tree.getroot()

    databaseInterface_el = root.find('dbmgr/databaseInterfaces')  # noqa
    default_el = root.find('dbmgr/databaseInterfaces/default')
    # TODO: [26.10.2021 burov_alexey@mail.ru]:
    # Элемент нужно обновлять, а не удалять. Другие настройки должны остаться
    # не тронутыми.
    databaseInterface_el.remove(default_el)

#     print(
#         f'MYSQL_USER={MYSQL_USER}',
#         f'MYSQL_PASSWORD={MYSQL_PASSWORD}',
#         f'MYSQL_DATABASE={MYSQL_DATABASE}',
#         sep='\n'
#     )

    assert MYSQL_USER and MYSQL_PASSWORD and MYSQL_DATABASE

    new_default_el = ET.fromstring(f"""
        <default>
            <type> mysql </type>
            <host> kbe-mariadb </host>
            <port> 0 </port>
            <auth>
                <username> {MYSQL_USER} </username>
                <password> {MYSQL_PASSWORD} </password>
            </auth>
            <databaseName> {MYSQL_DATABASE} </databaseName>
        </default>
    """)

#   print(ET.tostring(new_default_el, encoding='utf8', method='xml'))

    databaseInterface_el.append(new_default_el)

    dbmgr_el = root.find('dbmgr')
    # TODO: (3 nov. 2020 г. 12:35:19 burov_alexey@mail.ru)
    # Check node exists
    shareDB_el = ET.SubElement(dbmgr_el, 'shareDB')  # noqa
    shareDB_el.text = 'true'

    for name in ('baseapp', 'loginapp'):
        app_el = root.find(name)
        externalAddress_el = ET.SubElement(app_el, 'externalAddress')  # noqa
        externalAddress_el.text = HOST_ADDR

    tree.write(conf_path)

    print('The config "kbengine.xml" has been updated')


if __name__ == '__main__':
    main()
