import argparse, json, os, urllib, urllib2

# https://help.github.com/articles/creating-an-access-token-for-command-line-use/
# requires repo scope, Full control of private repositories
github_token = os.getenv('GITHUB_TOKEN')
if github_token is None:
    raise EnvironmentError('Environment variable GITHUB_TOKEN is missing')

def github_request(repo, branch, data = None):
    url = 'https://api.github.com/repos/{}/git/refs/heads/{}'.format(repo, branch)
    headers = { 'Authorization': 'token {}'.format(github_token) }

    request = urllib2.Request(url, headers = headers, data = data)
    return urllib2.urlopen(request).read()

def latest_commit(repo, branch):
    body = github_request(repo, branch)
    return json.loads(body)['object']['sha']

def update_last_commit(repo, branch, commit):
    data = json.dumps({ 'ref': 'refs/heads/{}'.format(branch), 'sha': commit })
    body = github_request(repo, branch, data)

def main(upstream_repo, fork_repo, branch):
    upstream_commit = latest_commit(upstream_repo, branch)
    fork_commit = latest_commit(fork_repo, branch)

    if upstream_commit == fork_commit:
        print('{} already up to date'.format(fork_repo))
    else:
        update_last_commit(fork_repo, branch, upstream_commit)
        print('{} updated'.format(fork_repo))

def args():
    parser = argparse.ArgumentParser(description='Sync github fork')
    parser.add_argument('upstream_repo', help='the upstream repository (like: octocat/Spoon-Knife)')
    parser.add_argument('fork_repo', help='your fork repository (like: YOUR_USERNAME/YOUR_FORK)')
    parser.add_argument('--branch', default='master', help='the branch to sync (default: master)')

    return parser.parse_args()

if __name__ == '__main__':
    args = args()
    main(args.upstream_repo, args.fork_repo, args.branch)
