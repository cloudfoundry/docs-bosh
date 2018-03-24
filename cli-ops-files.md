---
title: Operations Files
---

<p class="note">Note: Applies to CLI v2.</p>

It's usually necessary to apply an opinionated set of structural changes to a YAML document (manifest, cloud config, etc.) before submitting it to the CLI commands (`bosh create-env`, `bosh deploy`, etc.) for processing. Such changes could be an addition or removal of certain job properties, instance groups, changes to property values.

<p class="note">Note: Replacing values such as passwords and certificates is not considered a structural change. Refer to [CLI variable interpolation](cli-int.md) for details.</p>

To get a final YAML document one can apply desired changes once and save the result; however, over time it may become harder or just tedious to reapply these changes if base document changes. Additionally if it's necessary to have multiple slightly different changes on top of the base document for different teams existing editing tools may not be enough. To make such workflows easier you can encode a set of changes into one or more operations file.

A single operation represents a single change. An operations file is a YAML document that contains multiple operations that are to be applied serially to a different YAML document. Instead of storing all operations in a single file, they can be grouped logically into many operations files.

Several CLI commands such as `create-env`, `deploy` and `interpolate` allow to provide operations files via `--ops-file` flag to be applied before processing the document.

---
## Example <a id="example"></a>

Following is an operations file (`replace-name.yml`) with a single operation that replaces value of top level key `name` with a string `other-cf`:

```yaml
- type: replace
  path: /name
  value: other-cf
```

Given base YAML document (`base.yml`):

```yaml
name: my-cf
```

Result of applying above operations file to the base YAML document would be:

```yaml
name: other-cf
```

That could be demonstrated with the help of `bosh interpolate` command whose purpose is to simply apply operations files to base document and print the result:

```shell
$ bosh interpolate base.yml --ops-file replace-name.yml

name: other-cf
```

---
## Path syntax <a id="path"></a>

Each operation acts on a location within a YAML document. Path represents a location. It's important to note that path (location) does not represent what operation will be performed, just like lat & long do not represent what happens at a physical location.

Here are some path examples:

- `/`: matches document root
- `/0`: matches 0th item in the array at the root
- `/instance_groups/0`: matches 0th instance group within `instance_groups` array
- `/instance_groups/name=zookeeper`: matches instance group (hash) with a `name` key that has value `zookeeper`

All paths follow these rules:

- Paths can have multiple components separated by a `/`

- Paths always start at the root of the document with a `/`

- String components typically refer to hash keys (ex: `/key1`)
  - Strings ending with `?` refer to hash keys that may or may not exist
    - "optionality" carries over to the items to the right

- Integer components refer to array indices (ex: `/0`, `/-1`)

- Array index selection could be affected via `:prev` and `:next` (as of CLI v2.0.40+)

- Array insertion could be affected via `:before` and `:after` (as of CLI v2.0.40+)

- `-` component refers to an imaginary index after last array index (ex: `/-`)
  - If there is an array of length 3 (`[0,1,2]`), then `-` would refer to 4th non-existent position

- `key=val` component matches hashes within an array (ex: `/key=val`)
  - Values ending with `?` refer to array items that may or may not exist

Path components without "optional" (`?`) annotation imply that referenced location must exist within a document. Operation will fail to be performed if that location is not found. "Optional" annotation can be used to signify indifference to the presense of referenced location, making it possible for operation either to ignore it (while removal) or create it lazily (while replacement). If a component in a path is annotated as optional, components following it will be considered optional implicitly.

---
## Operations <a id="ops"></a>

There are currently two types of operations: replace and remove.

Replace operation can be used to append an item to an array of any length if last component of a path is a `-` (see above for details).

Following base YAML document is used with operations below:

```yaml
key: 1

key2:
  nested:
    super_nested: 2
  other: 3

array: [4,5,6]

items:
- name: item7
- name: item8
- name: item8
```

---
### Hash

```yaml
- type: replace
  path: /key
  value: 10
```

- sets `key` to `10`

```yaml
- type: remove
  path: /key
```

- removes `key`

```yaml
- type: replace
  path: /key_not_there
  value: 10
```

- errors because `key_not_there` is expected (does not have `?`)

```yaml
- type: remove
  path: /key_not_there
```

- again this errors because `key_not_there` is expected (does not have `?`)

```yaml
- type: replace
  path: /new_key?
  value: 10
```

- creates `new_key` because it ends with `?` and sets it to `10`

```yaml
- type: replace
  path: /key2/nested/super_nested
  value: 10
```

- requires that `key2` and `nested` hashes exist
- sets `super_nested` to `10`

```yaml
- type: remove
  path: /key2/nested/super_nested
```

- requires that `key2` and `nested` hashes exist
- removes `super_nested`

```yaml
- type: replace
  path: /key2/nested?/another_nested/super_nested
  value: 10
```

- requires that `key2` hash exists
- allows `nested`, `another_nested` and `super_nested` not to exist because `?` carries over to nested keys
- creates `another_nested` and `super_nested` before setting `super_nested` to `10`, resulting in:

  ```yaml
  ...
  key2:
    nested:
      another_nested:
        super_nested: 10
      super_nested: 2
    other: 3
  ```

---
### Array

```yaml
- type: replace
  path: /array/0
  value: 10
```

- requires `array` to exist and be an array
- replaces 0th item in `array` array with `10`

```yaml
- type: remove
  path: /array/0
```

- requires `array` to exist and be an array
- removes 0th item in `array`

```yaml
- type: replace
  path: /array/-
  value: 10
```

- requires `array` to exist and be an array
- appends `10` to the end of `array`

```yaml
- type: replace
  path: /array2?/-
  value: 10
```

- creates `array2` array since it does not exist
- appends `10` to the end of `array2`

```yaml
- type: replace
  path: /array/1:prev
  value: 10
```

- requires `array` to exist and be an array
- replaces 0th item in `array` array with `10`

```yaml
- type: replace
  path: /array/0:next
  value: 10
```

- requires `array` to exist and be an array
- replaces 1st item (starting at 0) in `array` array with `10`

```yaml
- type: replace
  path: /array/0:after
  value: 10
```

- requires `array` to exist and be an array
- inserts `10` after 0th item in `array` array

```yaml
- type: replace
  path: /array/0:before
  value: 10
```

- requires `array` to exist and be an array
- inserts `10` before 0th item at the beginning of `array` array

---
### Arrays of hashes

```yaml
- type: remove
  path: /items/name=item7
```

- finds and removes array item with matching key `name` with value `item7`

```yaml
- type: replace
  path: /items/name=item8/count
  value: 10
```

- errors because there are two values that have `item8` as their `name`

```yaml
- type: replace
  path: /items/name=item9?/count
  value: 10
```

- appends array item with matching key `name` with value `item9` because values ends with `?` and item does not exist
- creates `count` and sets it to `10` within created array item, resulting in:

  ```yaml
  ...
  items:
  - name: item7
  - name: item8
  - name: item8
  - name: item9
    count: 10
  ```

```yaml
- type: replace
  path: /items/name=item7:before
  value:
    name: item6
```

- finds array item with matching key `name` with value `item7`
- adds hash `name: item6` before found array item, resulting in:

  ```yaml
  ...
  items:
  - name: item6
  - name: item7
  - name: item8
  - name: item8
  ```

---
Next: [CLI Variable Interpolation](cli-int.md)

Previous: [CLI Environments](cli-envs.md)
