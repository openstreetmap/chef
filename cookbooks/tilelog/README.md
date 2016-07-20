# tilelog Cookbook

This cookbook contains the tile log processing / analysis tools. This includes creating the tile log summaries of the number of tiles downloaded from the tile caches.

## Requirements

#### cookbooks
- `tools` - tilelog needs the OSM tools cookbook.
- `git` - tilelog needs the OSM git cookbook to download the tile log analysis source.

#### packages
- `gcc` - for building the analysis tool.
- `make` - for building the analysis tool.
- `autoconf` - for building the analysis tool.
- `automake` - for building the analysis tool.
- `libboost-filesystem-dev` - a dependency of the analysis tool.
- `libboost-system-dev` - a dependency of the analysis tool.
- `libboost-program-options-dev` - a dependency of the analysis tool.

## Attributes

#### tilelog::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>[:tilelog][:source_directory]</tt></td>
    <td>String</td>
    <td>Directory in which the source is checked out and built.</td>
    <td><tt>/opt/tilelog</tt></td>
  </tr>
  <tr>
    <td><tt>[:tilelog][:input_directory]</tt></td>
    <td>String</td>
    <td>Directory in which the input log files can be found.</td>
    <td><tt>/store/logs/tile.openstreetmap.org</tt></td>
  </tr>
  <tr>
    <td><tt>[:tilelog][:source_directory]</tt></td>
    <td>String</td>
    <td>Directory in which the output analysis files are to be placed.</td>
    <td><tt>/store/planet/tile_logs</tt></td>
  </tr>
</table>

## Usage

#### tilelog::default
TODO: Write usage instructions for each cookbook.

e.g.
Just include `tilelog` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[tilelog]"
  ]
}
```

## License and Authors

Released under the [Apache 2.0 license](http://www.apache.org/licenses/LICENSE-2.0).

Authors: Matt Amos
