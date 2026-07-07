!!! note
    Examples use CLI v2.

This topic is written for release maintainers and describes how to set up Git LFS for storing release blobs and final releases as an alternative to S3 or other external blobstores.

## Overview

Git LFS (Large File Storage) allows you to manage release blobs alongside your release code in the same Git repository. Instead of distributing separate credentials for blob uploads, contributors use standard Git credentials. This simplifies access management and enables external contributors to bump dependencies without requiring separate blobstore access.

## Prerequisites

- **Git LFS client**: Install [Git LFS](https://git-lfs.com/) on your machine. Follow the [official installation instructions](https://git-lfs.com/).
- **Git server with LFS support**: Ensure your Git hosting provider supports Git LFS (GitHub, GitLab, Gitea, Bitbucket, etc.).
- **Understanding of LFS storage**: Be aware that your Git hosting provider may have storage and bandwidth quotas for LFS objects. Review their pricing and limits.

## Trade-offs

### Advantages

- **No separate credentials needed**: Uses standard Git credentials instead of requiring `config/private.yml` with blobstore access keys.
- **Simplified contributor workflow**: External contributors can add and update blobs using standard Git operations without needing special blobstore access.
- **Access control via Git**: Permissions are managed through your Git repository access model (teams, branches, etc.).
- **Enterprise-friendly**: Works in environments where obtaining public-facing S3 buckets is difficult or impossible.

### Disadvantages

- **Higher cost**: Git LFS is typically more expensive per GB than S3.
- **Storage and bandwidth quotas**: Most Git hosting providers impose limits on LFS storage and bandwidth, which may require paid plans for large releases.
- **Performance**: Very large blob files may be slower to download via Git LFS compared to S3.
- **Repository size**: Git LFS objects are stored in your repository history, which can impact repository clone times.

### Decision Matrix

| Scenario | Use Git LFS | Use S3 | Rationale |
|----------|-----------|--------|-----------|
| Internal release, small team | ✓ | - | Simpler access management via Git |
| Public open-source release | - | ✓ | S3 is more cost-effective for public distribution |
| Large blobs (>100MB each) | - | ✓ | S3 performs better for very large files |
| Enterprise, no public S3 allowed | ✓ | - | Git LFS works behind firewalls |
| External contributors need write access | ✓ | - | Avoids distributing blobstore credentials |
| Cost-sensitive | - | ✓ | S3 is cheaper for large-scale storage |

## Setup

### 1. Initialize Git LFS in Your Release Repository

Follow the [Git LFS getting started guide](https://git-lfs.com/) to initialize Git LFS in your release repository:

```shell
cd my-release
git lfs install
```

### 2. Track Blob Directories with Git LFS

Use `git lfs track` to configure `.gitattributes` for your blob directories:

```shell
git lfs track "blobs/**"
git lfs track "final_blobs/**"
```

This creates/updates your `.gitattributes` file with the appropriate Git LFS filter configuration.

Commit the `.gitattributes` file:

```shell
git add .gitattributes
git commit -m "Configure Git LFS for release blobs"
```

### 3. Configure `config/final.yml`

Update `config/final.yml` to use the local provider with `final_blobs` directory:

```yaml
---
name: my-release
blobstore:
  provider: local
  options:
    blobstore_path: final_blobs
```

Commit this configuration:

```shell
git add config/final.yml
git commit -m "Configure local blobstore with final_blobs directory"
```

### 4. Ensure `.gitignore` is Correct

Your `.gitignore` should include:

```
blobs/*
!blobs/.gitkeep
```

This ensures the `blobs/` directory exists but blob files are not tracked by Git (Git LFS handles them via `.gitattributes`). The `blobs/` directory contains local blob staging and should not be committed.

The `final_blobs/` directory should NOT be in `.gitignore` because Git LFS-tracked files must be committed to Git.

## Developer Workflow

### Adding a Blob

1. Add the blob to your release:

```shell
bosh add-blob ~/Downloads/some-package-1.0.0.tar.gz some-package-1.0.0.tar.gz
```

The `bosh add-blob` command copies the file to `blobs/` and updates `config/blobs.yml`.

2. Commit to Git:

```shell
git add config/blobs.yml
git commit -m "Add some-package 1.0.0 blob"
```

Git LFS automatically tracks the blob file via `.gitattributes` patterns.

### Creating a Final Release

1. Create the final release:

```shell
bosh create-release --final
```

This generates the final release tarball and places it in the `final_blobs/` directory.

2. Commit to Git:

```shell
git add config/blobs.yml config/index.yml
git commit -m "Finalize release v1.0.0"
git tag v1.0.0
```

The `final_blobs/` directory contents are automatically tracked by Git LFS via `.gitattributes`.

### For Contributors

External contributors follow the same workflow:

1. Clone the repository (Git LFS objects are downloaded automatically):

```shell
git clone https://github.com/your-org/my-release.git
```

2. Add or update blobs:

```shell
bosh add-blob ~/Downloads/new-dependency-2.0.0.tar.gz new-dependency-2.0.0.tar.gz
git add config/blobs.yml
git commit -m "Bump new-dependency to 2.0.0"
```

3. Push the changes (including LFS objects):

```shell
git push
```

No special credentials or access to a separate blobstore are required.

### Cloning a Release with Git LFS

When cloning a repository with Git LFS blobs, Git LFS automatically downloads all blob objects. For detailed information on cloning and pulling with Git LFS, see the [Git LFS documentation](https://git-lfs.com/).

```shell
git clone https://github.com/your-org/my-release.git
cd my-release
```

If LFS objects fail to download, you can manually pull them:

```shell
git lfs pull
```

## Migrating from S3 to Git LFS

If you're migrating an existing release from S3 to Git LFS:

1. Set up Git LFS in your repository as described in the Setup section above.
2. Download blobs from your current S3 blobstore.
3. Use `bosh add-blob` to add each blob to your release.
4. Commit the blobs and updated `config/blobs.yml` to Git (Git LFS automatically tracks them via `.gitattributes`).
5. Update `config/final.yml` to point to `final_blobs` with the local provider.

Refer to the [Git LFS documentation](https://git-lfs.com/) for details on working with large files and repositories.

## Troubleshooting

For Git LFS-specific troubleshooting (installation, authentication, object downloading), refer to the [Git LFS documentation](https://git-lfs.com/).

### Large Repository Size

If your repository becomes too large, consider:
- Archiving old final releases into separate branches
- Pruning old LFS objects (carefully, as this affects rebuild ability from older commits)
- Using shallow clones for development: `git clone --depth 1`

### LFS Quota Issues

If you hit Git hosting provider LFS quota limits:
- Review and optimize blob sizes
- Consider moving large static assets to S3 and having Git LFS track only references
- Upgrade to a higher storage tier on your Git hosting provider

### BOSH-Specific Issues

If `bosh add-blob` doesn't work as expected with Git LFS, ensure:
- `.gitattributes` is properly configured with the patterns shown in the Setup section
- You are committing the blobs to Git (Git LFS tracks them automatically via `.gitattributes`)
- Your `.gitignore` allows `final_blobs/` directory to be committed

## When to Use Git LFS

Use Git LFS for your release blobstore if:

- Your release team is internal or a controlled group where Git access management is sufficient
- You work in an enterprise environment where obtaining public-facing S3 buckets is difficult
- You want to simplify contributor workflow by avoiding separate blobstore credentials
- You can accept higher costs and potential storage/bandwidth quotas in exchange for simpler access management
- Your blobs are reasonably sized (< 100MB each for best performance)

Consider S3 or another external blobstore if:

- Your release is public and you need cost-effective, high-performance distribution
- You have very large blobs or high bandwidth requirements
- Cost is a primary concern
- You need fine-grained access control independent of Git repository access
