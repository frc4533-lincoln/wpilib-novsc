'''
frcutil
-- Because WPILib is just that much of a pain
'''
import requests
import xml.etree.ElementTree as ElemTree

import tomli_w
from github import Github

toml = {
    'toolchain_releases': {},
    'wpilib_releases': {},
    'ni_releases': {},
}

g = Github()

wpiorg = g.get_organization('wpilibsuite')

def toolchain():
    rels = toml['toolchain_releases']

    for rel in wpiorg.get_repo('opensdk').get_releases():
        version = rel.tag_name.removeprefix('v')

        [year, rev] = version.split('-')

        if int(rev) >= 7:
            if year not in rels:
                rels[year] = {}
            if version not in rels[year]:
                rels[year][version] = {}

            for asset in rel.assets:
                if (asset.name.startswith("cortexa9") and int(rev) >= 7):
                    parts = asset.name \
                        .removeprefix('cortexa9_vfpv3-roborio-academic-') \
                        .removesuffix('.tgz') \
                        .removesuffix('.zip') \
                        .split('-')

                    # Length checked to handle this properly:
                    #     cortexa9_vfpv3-roborio-academic-2023-aarch64-bullseye-linux-gnu-Toolchain-12.1.0.tgz
                    if len(parts) == 6:
                        [_, arch, os, _, _, gcc_version] = parts
                    else:
                        [_, arch, _, os, _, _, gcc_version] = parts

                    rels[year][version][f'{os}-{arch}'] = asset.browser_download_url

def wpilib():
    rels = toml['wpilib_releases']

    for rel in wpiorg.get_repo('allwpilib').get_releases():
        version = rel.tag_name.removeprefix('v')

        year = version.split('.')[0]

        if year not in rels:
            rels[year] = {'unstable': [], 'stable': []}

        if rel.prerelease:
            rels[year]['unstable'] += [version]
        else:
            rels[year]['stable'] += [version]

def ni_libs():
    for lib in ['chipobject', 'netcomm', 'runtime', 'visa']:
        body = requests.get(f'https://frcmaven.wpi.edu/artifactory/release/edu/wpi/first/ni-libraries/{lib}/maven-metadata.xml').content
        with open('/tmp/maven-metadata.xml', 'wb') as f:
            f.write(body)

        versions = []

        root = ElemTree.parse('/tmp/maven-metadata.xml').getroot()
        for elem in root.findall('./versioning/versions/version'):
            versions += [elem.text]

        versions.reverse()

        for version in versions:
            year = version.split('.')[0]

            if lib not in toml['ni_releases']:
                toml['ni_releases'][lib] = {}
            if year not in toml['ni_releases'][lib]:
                toml['ni_releases'][lib][year] = []

            toml['ni_releases'][lib][year] += [version]

toolchain()
wpilib()
ni_libs()

with open('frcutil_releases.toml', 'wb') as f:
    tomli_w.dump(toml, f)
