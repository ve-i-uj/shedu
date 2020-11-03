"""Modifies the kbengine.xml configuration file before start of a kbe server.

This script would be placed in the root directory of a project.
"""

import os.path
import xml.etree.ElementTree as ET


def main():
    proj_dir = os.path.dirname(__file__)
    conf_path = os.path.join(proj_dir, 'res', 'server', 'kbengine.xml')
    tree = ET.parse(conf_path)
    root = tree.getroot()
    
    # TODO: (3 nov. 2020 г. 12:16:40 burov_alexey@mail.ru)
    # configure username, pwd, db name
    databaseInterface_el = tree.find('dbmgr/databaseInterfaces')
    default_el = tree.find('dbmgr/databaseInterfaces/default')
    databaseInterface_el.remove(default_el)
    
    new_default_el = ET.fromstring("""
        <default>
            <type> mysql </type>
            <host> kbe-mariadb </host>
            <auth>  
                <username> kbe </username>
                <password> pwd123456 </password>
                <encrypt> true </encrypt>
            </auth>
            <databaseName> kbe </databaseName>
            <numConnections> 5 </numConnections>
        </default>
    """)
    
    databaseInterface_el.append(new_default_el)
    
    dbmgr_el = tree.find('dbmgr')
    # TODO: (3 nov. 2020 г. 12:35:19 burov_alexey@mail.ru)
    # Check node exists
    shareDB_el = ET.SubElement(dbmgr_el, 'shareDB')
    shareDB_el.text = 'true'
    
    tree.write(conf_path)
    
    print('The config "kbengine.xml" has been updated')


if __name__ == '__main__':
    main()