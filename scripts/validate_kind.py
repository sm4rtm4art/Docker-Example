#!/usr/bin/env python3
"""Optional kind smoke test. Requires kind v0.33.0 and a compatible kubectl."""
import argparse
import json
import subprocess
import uuid
from api_contract import run as contract
from validate import ROOT, REPORTS, QUICKSTART, command, free_port, wait_json, require

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--track', choices=('python', 'rust', 'java'), default='python')
args = parser.parse_args()
name = 'dockerlearn-check-' + uuid.uuid4().hex[:10]
image = 'task-api:' + name
REPORTS.mkdir(exist_ok=True)
kubeconfig = REPORTS / (name + '.kubeconfig')
manifest = REPORTS / (name + '.yaml')
source = ROOT / 'docker-mastery-multitrack/10-orchestration-intro'
forward = None
cluster_attempted = False
image_built = False
port = free_port()
base = ['kubectl', '--kubeconfig', str(kubeconfig), '-n', 'docker-learning']
try:
    command(['kind', 'version'])
    command(['kubectl', 'version', '--client'])
    require(name not in command(['kind', 'get', 'clusters'], capture=True).splitlines(), 'Cluster already exists')
    command(['docker', 'build', '-t', image, str(QUICKSTART / args.track)])
    image_built = True
    cluster_attempted = True
    command(['kind', 'create', 'cluster', '--name', name, '--config', str(source / 'kind.yaml'),
             '--image', 'kindest/node:v1.35.8@sha256:07b2536e30b803ed61d1677a79df6115f798ce64c80f9e22f6ed45afd09323c0',
             '--kubeconfig', str(kubeconfig), '--wait', '120s'])
    command(['kind', 'load', 'docker-image', image, '--name', name])
    manifest.write_text((source / 'task-api.yaml').read_text().replace('task-api:kind', image))
    command(base + ['apply', '-f', str(manifest)])
    command(base + ['rollout', 'status', 'deployment/task-api', '--timeout=180s'])
    with (REPORTS / f'kind-{args.track}-forward.log').open('w') as output:
        forward = subprocess.Popen(base + ['port-forward', '--address', '127.0.0.1', 'service/task-api', f'{port}:8080'],
                                   cwd=ROOT, stdout=output, stderr=output)
        url = f'http://127.0.0.1:{port}'
        wait_json(url + '/health')
        require(contract(url, REPORTS / f'kind-{args.track}-api.json'), 'kind API contract failed')
        forward.terminate()
        forward.wait(timeout=10)
        forward = None
    before = json.loads(command(base + ['get', 'pods', '-l', 'app=task-api', '-o', 'json'], capture=True))['items'][0]['metadata']['uid']
    command(base + ['delete', 'pod', '-l', 'app=task-api', '--wait=true', '--timeout=90s'])
    command(base + ['rollout', 'status', 'deployment/task-api', '--timeout=180s'])
    after = json.loads(command(base + ['get', 'pods', '-l', 'app=task-api', '-o', 'json'], capture=True))['items'][0]['metadata']['uid']
    require(before != after, 'Deployment did not replace the Pod')
    print('PASS: kind API and Pod replacement')
finally:
    if forward is not None:
        forward.terminate()
        forward.wait(timeout=10)
    if kubeconfig.exists():
        logs = command(base + ['logs', 'deployment/task-api', '--tail=100'], capture=True, check=False)
        (REPORTS / f'kind-{args.track}.log').write_text(logs or '')
    if cluster_attempted:
        command(['kind', 'delete', 'cluster', '--name', name], check=False)
    if image_built:
        command(['docker', 'image', 'rm', image], check=False)
    kubeconfig.unlink(missing_ok=True)
    manifest.unlink(missing_ok=True)
