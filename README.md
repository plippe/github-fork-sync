# GitHub fork sync

> A fork is a copy of a repository. Forking a repository allows you to freely
> experiment with changes without affecting the original project.
>
> ...
>
> You might fork a project in order to propose changes to the upstream, or
> original, repository. In this case, it's good practice to regularly sync your
> fork with the upstream repository. To do this, you'll need to use Git on the
>  command line. You can practice setting the upstream repository using the
> same octocat/Spoon-Knife repository you just forked!
>
> -- *[GitHub][1]*

Who has the time to manually sync their forks ? Don't waste time, automate this.

### GitHub token
First, you need a [GitHub token][2] to use their API. The token requires the
*repo* scope (Full control of private repositories). Store it and don't lose it.

### Run as a script
```
export GITHUB_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

python github_fork_sync.py --help
python github_fork_sync.py $UPSTREAM $FORK
```

Don't hesitate to add this as a cron job to have the sync run periodically.

### Run as an AWS Lambda
```
./aws/cloudformation.sh

# Create the stack
./aws/cloudformation.sh create $S3_BUCKET $S3_KEY $GITHUB_TOKEN

# Add repos to sync
./aws/cloudformation.sh add-sync $UPSTREAM1 $FORK1 $BRANCH1
./aws/cloudformation.sh add-sync $UPSTREAM2 $FORK2 $BRANCH2
./aws/cloudformation.sh add-sync $UPSTREAM3 $FORK3 $BRANCH3

# Delete the stack
./aws/cloudformation.sh delete $S3_BUCKET $S3_KEY
```

The lambda will be triggered daily for each repo.


[1]: https://help.github.com/articles/fork-a-repo/
[2]: https://help.github.com/articles/creating-an-access-token-for-command-line-use/
