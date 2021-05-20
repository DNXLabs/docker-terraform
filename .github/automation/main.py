import os
import json
import requests
import sys
import semver
import github3
from jinja2 import Environment, FileSystemLoader

LATEST_RELEASES_PATH_TF = 'https://api.github.com/repos/hashicorp/terraform/releases/latest'
LATEST_RELEASES_PATH_DNX_TF = 'https://api.github.com/repos/DNXLabs/docker-terraform/releases/latest'
GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
GITHUB_REPOSITORY_ID = os.getenv('GITHUB_REPOSITORY_ID', '143522585')
DEFAULT_BRANCH = os.getenv('DEFAULT_BRANCH', 'master')


# Terraform upstream
response_release_tf = requests.get(
    LATEST_RELEASES_PATH_TF,
    headers={'Authorization': 'token ' + GITHUB_TOKEN})
release_tf_json_obj = json.loads(response_release_tf.text)
tag_name_tf = release_tf_json_obj.get('tag_name').replace('v', '')
draft_tf = release_tf_json_obj.get('draft')
prerelease_tf = release_tf_json_obj.get('prerelease')

# DNX docker terraform
response_release_docker_tf = requests.get(
    LATEST_RELEASES_PATH_DNX_TF,
    headers={'Authorization': 'token ' + GITHUB_TOKEN})
release_docker_tf_json_obj = json.loads(response_release_docker_tf.text)
tag_name_docker_tf = release_docker_tf_json_obj.get('tag_name').replace('v', '').split('-')[0]

if draft_tf or prerelease_tf:
    print('The release is a draft of prelease.')
    sys.exit()

print('Upstream version: %s' % tag_name_tf)
print('DNX docker-terraform version: %s' % tag_name_docker_tf)

if semver.compare(tag_name_tf, tag_name_docker_tf) != 1:
    print('Nothing to do, the upstream is in the same version or lower version.')
    sys.exit()

# Generate Dockerfile template with new upstream version
root = os.path.dirname(os.path.abspath(__file__))
templates_dir = os.path.join(root, 'templates')
env = Environment( loader = FileSystemLoader(templates_dir) )
template = env.get_template('Dockerfile.j2')
filename = os.path.join(root, 'Dockerfile')

with open(filename, 'w') as fh:
    fh.write(template.render(
        tag_name_tf = tag_name_tf
    ))

# Add and push changes to github repo
with open('Dockerfile') as f:
    docker_file = f.read()

# Connect to GitHub API and push the changes.
github = github3.login(token=GITHUB_TOKEN)
repository = github.repository_with_id(GITHUB_REPOSITORY_ID)

github_dockerfile = repository.file_contents('/Dockerfile', ref=DEFAULT_BRANCH)

pushed_index_change = github_dockerfile.update(
    'Bump Terraform version to v%s' % tag_name_tf,
    docker_file.encode('utf-8'),
    branch=DEFAULT_BRANCH
)

print('Pushed commit {} to {} branch:\n    {}'.format(
    pushed_index_change['commit'].sha,
    DEFAULT_BRANCH,
    pushed_index_change['commit'].message,
))

#Create new release
data = {
    'name': '%s-dnx1' % tag_name_tf,
    'tag_name': tag_name_tf,
    'body': '- Bump Terraform version to v%s.' % tag_name_tf,
    'draft': True,
    'prerelease': True
}

headers = {
    'Authorization': 'token %s' % GITHUB_TOKEN,
    'Accept': 'application/vnd.github.v3+json'
}

response_new_release = requests.post(
    'https://api.github.com/repos/DNXLabs/docker-terraform/releases',
    data=json.dumps(data),
    headers=headers
)