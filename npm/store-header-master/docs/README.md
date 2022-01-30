📢 Use this project, [contribute](https://github.com/vtex-apps/store-header) to it or open issues to help evolve it using [Store Discussion](https://github.com/vtex-apps/store-discussion).
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-0-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

# Header

The Header app is responsible for displaying a **navigation bar** fixed on a store's page upper side. 
Other blocks that are important for user navigation are found in the Header, for example the store's [logo](https://vtex.io/docs/components/all/vtex.store-components/logo), the [minicart](https://vtex.io/docs/components/all/vtex.minicart/), user [login](https://vtex.io/docs/components/all/vtex.login/) and [search bar](https://vtex.io/docs/components/all/vtex.store-components/search-bar).

![header](https://user-images.githubusercontent.com/52087100/74090325-b6235d00-4a88-11ea-8227-317f93204d8f.png) 

## Configuration

1. Add the `store-header` app to your theme's dependencies in `manifest.json`: 

```json
  dependencies: {
    "vtex.store-header": "2.x"
  }
```

Now, you are able to use all blocks exported by the `store-header` app. Check out the full list below:

| Block name | Description | 
| --------  | ------------ | 
| `header-layout.desktop` | ![https://img.shields.io/badge/-Mandatory-red](https://img.shields.io/badge/-Mandatory-red) Defines the Header layout for desktop device through `header-row` blocks. | 
| `header-layout.mobile`| Defines the Header layout for mobile device through `header-row` blocks. |
| `header-row` | ![https://img.shields.io/badge/-Mandatory-red](https://img.shields.io/badge/-Mandatory-red) Create Header lines according to your store needs. |  
| `header-border` | Adds a `1px` margin to a Header row. | 
| `header-force-center` | Centralizes its children blocks in a Header row. | 
| `header-spacer` | Adds spacing between blocks throughout a Header row. | 

2. Declare the two `header-layout` blocks, allowing you to define how the Header should be displayed for both mobile and desktop:

```json
{
  "header": {
    "blocks": [
      "header-layout.desktop",
      "header-layout.mobile"
    ]
  },
```

:information_source: *The Header does not need to be declared in a specific template of your theme, once the app is defined as default store interface element in the `interfaces.json` file. This means that Store Framework will reproduce the configurations defined in the file you just created for all store templates behind the scenes. If you want to apply different configurations to each store template, check the **advanced configurations** section below.*


4. Configure both `header-layout.desktop` and `header-layout.mobile`, declaring `header-row` to create Header lines according to your store needs. 

```json
{
  "header": {
    "blocks": [
      "header-layout.desktop",
      "header-layout.mobile"
    ]
  },
  "header-layout.desktop": {
    "children": [
      "header-row#1-desktop",
      "header-row#2-desktop",
      "header-row#3-desktop",
      "header-row#4-desktop"
    ]
  },
```

:warning: *In the example above, we configured 4 different levels for `header-layout.desktop`. It will thus be possible to replicate the Header displayed above sheltering the telemarketing functionalities (when activated), a notification, links to pages and every other blocks, such as Logo, Menu, etc. **Remember that the number of `header-row`s should meet your business needs**, determining how many Header lines you want to apply to your store.*

5. Configure each of the `header-row`s , applying props and declaring the desired store blocks for each line. To correctly structure your Header, you should check the [documentation](https://vtex.io/docs/components/all) for each of the desired blocks. The most commonly used are [Logo](https://vtex.io/docs/components/all/vtex.store-components/logo), [Minicart](https://vtex.io/docs/components/all/vtex.minicart/) and [Menu](https://vtex.io/docs/components/all/vtex.menu/). In the example below, we will configure the `header-row#1-desktop` as [Telemarketing](https://vtex.io/docs/components/all/vtex.telemarketing/):

```json
"header-row#1-desktop": {
  "children": [
    "telemarketing"
  ],
  "props": {
    "fullWidth": true
  }
},
```

- `header-row` props: 

| Prop name  | Type      | Description                                                                                       | Default value |
| ---------- | --------- | ------------------------------------------------------------------------------------ | ------------- |
| `zIndex` | `Number` | CSS property that controls the vertical stacking order of elements for overlapping.                                                                      | `0`         |
| `sticky` | `Boolean` | Whether the Header margin should be fixed on the layout (`true`) or not (`false`)                                                                    | `false`          |
| `fullWidth` | `Boolean` | Whether the Header should take the full width of the screen or not                                                                   | `true`          |
| `inverted` | `Boolean` | Whether the row will use the base color (`false`) or the inverted base color (`true`) as defined in `styles.json`.                                                                    | `false`          |

:warning: ***Repeat step 4 for any other `header-rows` you may have in the `header-layout.desktop`**. Remember to declare the desired blocks for each row, as we declared the Telemarketing block for the `header-row#1-desktop`, and properly configure all blocks using props. Once it is all finished, **redo steps 3 and 4 to define your `header-layout.mobile` as well***.

Three blocks can be added as `header-row`'s children in order to customize your Header row layout: `header-border`, `header-force-center` and `header-spacer`. 

- **`header-border`**:

When declared, the `header-border` block adds a `1px` margin to your store's Header.

```json
"header-row#2-desktop": {
  "children": [
    "header-border",
    "notification.bar#home"
  ],
  "props": {
    "fullWidth": "true"
  }
},
"notification.bar#home": {
  "props": {
    "content": "SELECTED ITEMS ON SALE! CHECK IT OUT!"
  }
},
```

| Prop name  | Type      | Description                                                                                       | Default value |
| ---------- | --------- | ------------------------------------------------------------------------------------ | ------------- |
| `sticky` | `Boolean` | Whether the Header margin should be fixed in the layout or not                                                                       | `false`          |

- **`header-force-center`**

When passed on, the `header-force-center` centralizes its children blocks in a Header row, for example: 

```json
"header-row#4-desktop": {
  "props": {
    "blockClass": "main-header",
    "horizontalAlign": "center",
    "verticalAlign": "center",
    "preventHorizontalStretch": true,
    "preventVerticalStretch": true,
    "fullWidth": true
  },
  "children": ["header-force-center"]
},  
"header-force-center": {
  "children":[
    "logo#desktop"
  ]
},
"logo#desktop": {
  "props": {
    "title": "Logo",
    "href": "/",
    "url": "https://storecomponents.vteximg.com.br/arquivos/store-theme-logo.png",
    "width": "180"
  }
},
```

![header-force-center](https://user-images.githubusercontent.com/52087100/76665339-2d577f80-6566-11ea-981d-3f4cdaec1a2b.png)

- **`header-spacer`**: 

The `header-spacer` is tasked with adding spacing between blocks throughout the Header rows. For example:

```json
"header-row#3-desktop": {
  "children": [
    "vtex.menu@2.x:menu#websites",
    "header-spacer",
    "vtex.menu@2.x:menu#institutional"
  ],
  "props": {
    "blockClass": "menu-link",
    "inverted": "true"
  }
},
```

In practice, it will make all blocks declared before it position themselves to the left on the screen, whereas blocks that are declared after will be positioned to the right. Considering that the Menus were properly declared and configured in the theme code, we would have the following: 

![header-spacer](https://user-images.githubusercontent.com/52087100/74090331-c8050000-4a88-11ea-8566-98097b18c83d.png)

### Advanced configuration

Automatic behind the scenes Header reproduction in every store template is only possible because it is defined as default store interface elements in the `interfaces.json` file from Store Theme. 

This definition in `interfaces.json` enables Store Framework to identify the Header block declared just once in a `blocks.jsonc` file and reproduce it as default for all other templates.

To overwrite this automatic duplication in `interfaces.json` and use new configurations in different templates, refer to the step-by-step of the following recipe: [Customizing the Header and Footer](https://vtex.io/docs/recipes/layout/customizing-the-header-and-footer-blocks-by-page). 

## Customization

In order to apply CSS customizations in these and other blocks, follow the instructions given in the recipe on [Using CSS Handles for store customization](https://vtex.io/docs/recipes/style/using-css-handles-for-store-customization). 
| CSS Handles          | 
---------------------- |
| `container`          |                       
| `leanMode`           |                        
| `topMenuContainer`   | 
| `topMenuLogo`        |              
| `topMenuSearchBar`   |     
| `topMenuIcons`       |             
| `topMenuCollapsible` |   
| `forceCenter`        |   
| `forceCenterInnerContainer` |   
| `headerBorder` | 
| `headerSpacer` | 
| `headerStickyRow` | 
| `headerRowContentContainer` |

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
