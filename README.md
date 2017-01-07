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
First, you need a [GitHub token][2] to use the API. The token requires the
*repo* scope (Full control of private repositories). Save it as an environment
variable named `GITHUB_TOKEN`.

```
export GITHUB_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Run as a script
```
python github-fork-sync.py --help
python github-fork-sync.py UPSTREAM_OWNER/UPSTREAM_REPOSITORY YOUR_USERNAME/YOUR_FORK
```

[1]: https://help.github.com/articles/fork-a-repo/
[2]: https://help.github.com/articles/creating-an-access-token-for-command-line-use/
