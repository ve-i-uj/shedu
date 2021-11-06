"""Modifies the kbengine.xml configuration file before start of a kbe server.

This script would be placed in the root directory of a project.
"""

import os
import xml.etree.ElementTree as ET

HOST_ADDR = '0.0.0.0'


def main():
    proj_dir = os.path.dirname(__file__)
    conf_path = os.path.join(proj_dir, 'res', 'server', 'kbengine.xml')
    # TODO: [26.10.2021 burov_alexey@mail.ru]:
    # Проверка, что путь существует иначе запись в лог и выход с ошибкой (exit 1)
    tree = ET.parse(conf_path)
    root = tree.getroot()
    
    # TODO: (3 nov. 2020 г. 12:16:40 burov_alexey@mail.ru)
    # configure username, pwd, db name
    databaseInterface_el = root.find('dbmgr/databaseInterfaces')  # noqa
    default_el = root.find('dbmgr/databaseInterfaces/default')
    # TODO: [26.10.2021 burov_alexey@mail.ru]:
    # Элемент нужно обновлять, а не удалять. Другие настройки должны остаться
    # не тронутыми.
    databaseInterface_el.remove(default_el)
    
    new_default_el = ET.fromstring("""
        <default>
            <type> mysql </type>
            <host> kbe-mariadb </host>
            <port> 0 </port>
            <auth>  
                <username> kbe </username>
                <password> pwd123456 </password>
            </auth>
            <databaseName> kbe </databaseName>
        </default>
    """)
    
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