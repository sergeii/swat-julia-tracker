# -*- coding: utf-8 -*-
import os

from unipath import Path
from fabric.api import *


env.kits = {
    'swat4': {
        'mod': 'Mod',
        'content': 'Content',
        'server': 'Swat4DedicatedServer.exe',
        'ini': 'Swat4DedicatedServer.ini',
    },
    'swat4exp': {
        'mod': 'ModX',
        'content': 'ContentExpansion',
        'server': 'Swat4XDedicatedServer.exe',
        'ini': 'Swat4XDedicatedServer.ini',
    },
}

env.roledefs = {
    'ucc': ['vm-ubuntu-swat'],
    'server': ['vm-ubuntu-swat'],
}

env.paths = {
    'here': Path(os.path.dirname(__file__)).parent,
}

env.paths.update({
    'dist': env.paths['here'].child('dist'),
    'compiled': env.paths['here'].child('compiled'),
})

env.ucc = {
    'path': Path('/home/sergei/swat4ucc/'),
    'git': 'git@home:public/swat4#origin/ucc',
    'packages': (
        ('Utils', 'git@home:swat/swat-utils'),
        ('HTTP', 'git@home:swat/swat-http'),
        ('Julia', 'git@home:swat/swat-julia'),
        ('JuliaTracker', 'git@home:swat/swat-julia-tracker'),
    ),
}

env.server = {
    'path': Path('/home/sergei/swat4server/'),
    'git': 'git@home:public/swat4#origin/server-bs',
    'settings': {
        '+[Engine.GameEngine]': (
            'ServerActors=Utils.Package',
            'ServerActors=HTTP.Package',
            'ServerActors=Julia.Core',
            'ServerActors=JuliaTracker.Extension',
        ),
        '[Julia.Core]': (
            'Enabled=True',
        ),
        '[JuliaTracker.Extension]': (
            'Enabled=True',
            'Key=1234',
            'URL=http://192.168.1.20:8000/stream/',
            'URL=http://192.168.1.101:8123/',
            'Attempts=5',
            'Feedback=True',
            'Compatible=False',
        ),
    }
}

env.dist = {
    'version': '1.2.0',  # also change version in Extension, README, CHANGES
    'extra': (
        env.paths['here'].child('LICENSE'),
        env.paths['here'].child('README.html'),
        env.paths['here'].child('CHANGES.html'),
    )
}