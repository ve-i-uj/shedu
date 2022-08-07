"""The script modifies the kbengine.xml configuration file so KBEngine can work with docker.

It would be placed in the root directory of the assets.
"""

import argparse
import logging
import shutil
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

HOST_ADDR = '0.0.0.0'
TITLE = ('The script modifies the kbengine.xml configuration file so KBEngine '
         'can work with docker.')
FORMAT = '[%(levelname)s] %(asctime)s [%(filename)s:%(lineno)s - %(funcName)s()] %(message)s'

logger = logging.getLogger(__file__)


def read_args():
    parser = argparse.ArgumentParser(description=TITLE)
    parser.add_argument('--kbe-assets-path', dest='kbe_assets_path', type=str,
                        required=True,
                        help='The path to the game assets')
    parser.add_argument('--env-file', dest='env_file_path', type=str,
                        required=True,
                        help='Settings file')
    parser.add_argument('--log-level', dest='log_level', type=str,
                        default='DEBUG',
                        choices=logging._nameToLevel.keys(),
                        help='Settings file')

    return parser.parse_args()


def setup_root_logger(level_name: str):
    level = logging.getLevelName(level_name)
    logger = logging.getLogger()
    logger.setLevel(level)
    stream_handler = logging.StreamHandler(sys.stdout)
    formatter = logging.Formatter(FORMAT)
    stream_handler.setFormatter(formatter)
    logger.handlers = [stream_handler]
    logger.info(f'Logger was set (log level = "{level_name}")')


def check_settings(settings: dict) -> bool:
    """Check settings file."""
    res = True
    for name, value in settings.items():
        value = value.strip()
        if name == 'MYSQL_DATABASE' and not value:
            logger.error('The variable "MYSQL_DATABASE" is empty')
            res = False
        if name == 'MYSQL_USER' and not value:
            logger.error('The variable "MYSQL_USER" is empty')
            res = False
        if name == 'MYSQL_PASSWORD' and not value:
            logger.error('The variable "MYSQL_PASSWORD" is empty')
            res = False

    return res


def main():
    namespace = read_args()
    setup_root_logger(level_name=namespace.log_level)
    kbengine_xml_path = Path(namespace.kbe_assets_path) / 'res' / 'server' / 'kbengine.xml'
    if not kbengine_xml_path.exists():
        logger.error('There is no kbengine.xml by path "%s"', kbengine_xml_path)
        sys.exit(1)

    settings_path = Path(namespace.env_file_path)
    if not settings_path.exists():
        logger.error('There is no settings env file by path "%s"', settings_path)
        sys.exit(1)

    settings: dict[str, str] = {}
    for line in settings_path.open():
        if not line.strip() or line.strip().startswith('#'):
            continue
        var_name, value = line.split('=', 1)
        if not var_name:
            logger.warning('A strange line is in config file ("%s")', line)
            continue
        settings[var_name] = value

    if not check_settings(settings):
        sys.exit(1)

    logger.info('Copy origin "kbengine.xml" (to "kbengine.xml.bak") ')
    shutil.copyfile(kbengine_xml_path,
                    kbengine_xml_path.with_suffix(kbengine_xml_path.suffix + '.bak'))

    tree = ET.parse(kbengine_xml_path)
    root = tree.getroot()

    dbmgr_el = root.find('dbmgr')
    if dbmgr_el is None:
        dbmgr_el = ET.SubElement(root, 'dbmgr')

    databaseInterface_el = dbmgr_el.find('databaseInterfaces')  # noqa
    if databaseInterface_el is None:
        databaseInterface_el = ET.SubElement(dbmgr_el, 'databaseInterfaces')

    default_el = databaseInterface_el.find('default')
    if default_el is None:
        default_el = ET.SubElement(databaseInterface_el, 'default')

    new_default_el = ET.fromstring(f"""
        <default>
            <type> mysql </type>
            <host> kbe-mariadb </host>
            <port> 0 </port>
            <auth>
                <username> {settings['MYSQL_USER']} </username>
                <password> {settings['MYSQL_PASSWORD']} </password>
            </auth>
            <databaseName> {settings['MYSQL_DATABASE']} </databaseName>
        </default>
    """)

    to_update_els = [el for el in new_default_el if el is not new_default_el]
    for new_el in to_update_els:
        el = default_el.find(new_el.tag)
        if el is not None:
            default_el.remove(el)
        default_el.append(new_el)

    logger.info('Updated elements: {tags})'.format(
        tags=', '.join(f'"{el.tag}"' for el in to_update_els))
    )

    shareDB_el = dbmgr_el.find('shareDB')
    if shareDB_el is None:
        shareDB_el = ET.SubElement(dbmgr_el, 'shareDB')
    shareDB_el.text = 'true'

    logger.info('Updated "shareDB"')

    for name in ('baseapp', 'loginapp'):
        app_el = root.find(name)
        if app_el is None:
            app_el = ET.SubElement(root, name)

        externalAddress_el = app_el.find('externalAddress')
        if externalAddress_el is None:
            externalAddress_el = ET.SubElement(app_el, 'externalAddress')
        externalAddress_el.text = HOST_ADDR

        logger.info(f'Updated {name} "externalAddress"')

    tree.write(kbengine_xml_path)

    logger.info(f'The config "{kbengine_xml_path}" has been updated')


if __name__ == '__main__':
    main()
