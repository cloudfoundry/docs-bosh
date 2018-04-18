---
schema: true
---

# Runtime Config

## Runtime Config {: # }

The runtime config defines IaaS agnostic configuration that applies to all deployments.

### `addons[]` {: #addons }

Specifies the addons to be applied to all deployments.

 * *Use*: Optional
 * *Type*: array

> #### `exclude` {: #addons.exclude }
> 
> Specifies exclusion placement rules.
> 
>  * *Use*: Optional
>  * *Details*: [See Schema](#def-placement_rules)
> 
> #### `include` {: #addons.include }
> 
> Specifies inclusion placement rules.
> 
>  * *Use*: Optional
>  * *Details*: [See Schema](#def-placement_rules)
> 
> #### `jobs[]` {: #addons.jobs }
> 
> Specifies the name and release of release jobs to be colocated.
> 
>  * *Use*: Optional
>  * *Type*: array
> 
> > ##### `name` {: #addons.jobs.name }
> > 
> > The job name.
> > 
> >  * *Use*: Required
> >  * *Type*: string
> > 
> > ##### `properties` {: #addons.jobs.properties }
> > 
> > Specifies job properties. Properties allow the Director to configure jobs to a specific environment.
> > 
> >  * *Use*: Optional
> >  * *Type*: object
> > 
> > 
> > ##### `release` {: #addons.jobs.release }
> > 
> > The release where the job exists.
> > 
> >  * *Use*: Required
> >  * *Type*: string
> > 
> 
> #### `name` {: #addons.name }
> 
> A unique name used to identify and reference the addon.
> 
>  * *Use*: Optional
>  * *Type*: string
> 

### `releases[]` {: #releases }

Specifies the releases used by the addons.

 * *Use*: Required
 * *Type*: array

> #### `name` {: #releases.name }
> 
> Name of a release name used by an addon
> 
>  * *Use*: Required
>  * *Type*: string
> 
> #### `sha1` {: #releases.sha1 }
> 
> SHA1 of asset referenced via URL. Works with CLI v2.
> 
>  * *Use*: Optional
>  * *Type*: string
>  * *Example*: `"332ac15609b220a3fdf5efad0e0aa069d8235788"`
> 
> #### `url` {: #releases.url }
> 
> URL of a release to download. Works with CLI v2.
> 
>  * *Use*: Optional
>  * *Type*: string
>  * *Example*: `"https://bosh.io/d/github.com/cloudfoundry/syslog-release?v=11"`
> 
> #### `version` {: #releases.version }
> 
> The version of the release to use. Version cannot be `latest`; it must be specified explicitly.
> 
>  * *Use*: Required
>  * *Type*: string
> 

### `tags` {: #tags }

Specifies key value pairs to be sent to the CPI for VM tagging. Combined with deployment level tags during the deploy.

 * *Use*: Optional
 * *Type*: object
 * *Example*: `{
  "business_unit": "marketing",
  "email_contact": "ops@marketing.example.com"
}`


## Placement Rules {: #def-placement_rules }

Placement rules for `include` and `exclude` directives.

> #### `deployments` {: #def-placement_rules.deployments }
> 
> Matches based on deployment names.
> 
>  * *Use*: Optional
>  * *Type*: array
> 
> #### `jobs[]` {: #def-placement_rules.jobs }
> 
> Matches based on jobs running on the instance group.
> 
>  * *Use*: Optional
>  * *Type*: array
> 
> > ##### `name` {: #def-placement_rules.jobs.name }
> > 
> > Matching job name.
> > 
> >  * *Use*: Required
> >  * *Type*: string
> > 
> > ##### `release` {: #def-placement_rules.jobs.release }
> > 
> > Matching release name.
> > 
> >  * *Use*: Required
> >  * *Type*: string
> > 
> 
> #### `networks` {: #def-placement_rules.networks }
> 
> Matches based on network names.
> 
>  * *Use*: Optional
>  * *Type*: array
> 
> #### `stemcell[]` {: #def-placement_rules.stemcell }
> 
> Matches based on stemcell used
> 
>  * *Use*: Optional
>  * *Type*: array
> 
> > ##### `os` {: #def-placement_rules.stemcell.os }
> > 
> > Matches stemcell's operating system.
> > 
> >  * *Use*: Required
> >  * *Type*: string
> >  * *Example*: `"ubuntu-trusty"`
> > 
> 
