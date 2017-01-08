from github_fork_sync import github_fork_sync

def handler(event, context):
    assert 'upstream_repo' in event
    assert 'fork_repo' in event
    assert 'branch' in event

    return github_fork_sync(
        event['upstream_repo'],
        event['fork_repo'],
        event['branch'])
