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

### Setup
First, you need a [GitHub token][2] to use their API. The token requires the
*repo* scope (Full control of private repositories). Save it as an environment
variable named `GITHUB_TOKEN`.

```
export GITHUB_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Run as a script
```
python github_fork_sync.py --help
python github_fork_sync.py $REPO $FORK
```

Don't hesitate to add this as a cron job to have the sync run periodically.

### Run as an AWS Lambda
Setting this up on AWS Lambda, is a 3 step process:
```
# Create lambda package
zip -j /tmp/lambda.zip aws/lambda.py github_fork_sync.py

# Move lambda package to s3
aws s3 mb s3://$S3_BUCKET
aws s3 mv /tmp/lambda.zip s3://$S3_BUCKET/$S3_KEY

# Create cloudformation stack
cloudformation_parameters="ParameterKey=LambdaPackageS3Bucket,ParameterValue=$S3_BUCKET "
cloudformation_parameters+="ParameterKey=LambdaPackageS3Key,ParameterValue=$S3_KEY "
cloudformation_parameters+="ParameterKey=GitHubToken,ParameterValue=$GITHUB_TOKEN "
cloudformation_parameters+="ParameterKey=GitHubUpstream,ParameterValue=$REPO "
cloudformation_parameters+="ParameterKey=GitHubFork,ParameterValue=$FORK "

aws cloudformation create-stack \
  --stack-name $STACK_NAME \
  --template-body file://aws/cloudformation.yml \
  --parameters "$cloudformation_parameters" \
  --capabilities CAPABILITY_NAMED_IAM
```

Once the lambda is deployed, it will be triggered daily.


[1]: https://help.github.com/articles/fork-a-repo/
[2]: https://help.github.com/articles/creating-an-access-token-for-command-line-use/
