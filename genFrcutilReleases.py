'''
frcutil
-- Because WPILib is just that much of a pain
'''
import requests
import xml.etree.ElementTree as ElemTree

import tomli_w
from github import Github

toml = {
    "toolchain_releases": {},
    "wpilib_releases": {},
    "ni_releases": {},
}

g = Github()

wpiorg = g.get_organization("wpilibsuite")

def toolchain():
    global toml
    rels = toml['toolchain_releases']

    for rel in wpiorg.get_repo("opensdk").get_releases():
        version = rel.tag_name.removeprefix("v")

        [year, rev] = version.split("-")

        if int(rev) >= 7:
            if not rels.__contains__(year):
                rels[year] = {}
            if not rels[year].__contains__(version):
                rels[year][version] = {}

            for asset in rel.assets:
                if (asset.name.startswith("cortexa9") and int(rev) >= 7):
                    print(f" > {asset.name}")

                    parts = asset.name \
                        .removeprefix("cortexa9_vfpv3-roborio-academic-") \
                        .removesuffix(".tgz") \
                        .removesuffix(".zip") \
                        .split("-")

                    # Length checked to handle this properly:
                    #     cortexa9_vfpv3-roborio-academic-2023-aarch64-bullseye-linux-gnu-Toolchain-12.1.0.tgz
                    if parts.__len__() == 6:
                        [_, arch, os, _, _, gcc_version] = parts
                    else:
                        [_, arch, _, os, _, _, gcc_version] = parts

                    rels[year][version][f"{os}-{arch}"] = asset.browser_download_url

def wpilib():
    global toml
    rels = toml['wpilib_releases']

    for rel in wpiorg.get_repo("allwpilib").get_releases():
        version = rel.tag_name.removeprefix("v")

        year = version.split(".")[0]

        if not rels.__contains__(year):
            rels[year] = {"unstable": [], "stable": []}

        if rel.prerelease:
            rels[year]['unstable'] += [version]
        else:
            rels[year]['stable'] += [version]

def ni_libs():
    for lib in ['chipobject', 'netcomm', 'runtime', 'visa']:
        body = requests.get(f"https://frcmaven.wpi.edu/artifactory/release/edu/wpi/first/ni-libraries/{lib}/maven-metadata.xml").content
        f = open("/tmp/maven-metadata.xml", 'w')
        f.write(body.decode('utf8'))
        f.close()

        versions = []

        root = ElemTree.parse('/tmp/maven-metadata.xml').getroot()
        for elem in root.findall('./versioning/versions/version'):
            versions += [elem.text]

        versions.reverse()

        for version in versions:
            year = version.split(".")[0]

            if not toml['ni_releases'].__contains__(lib):
                toml['ni_releases'][lib] = {}
            if not toml['ni_releases'][lib].__contains__(year):
                toml['ni_releases'][lib][year] = []

            toml['ni_releases'][lib][year] += [version]

toolchain()
wpilib()
ni_libs()

print(tomli_w.dumps(toml))
