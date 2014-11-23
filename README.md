# Paged Collection View

This project is an implementation of a paged collection view that allows for a peek of the next and previous pages, as per a bet between myself and [Jake MacMullin](https://github.com/jmacmullin) ([@jmacmullin](https://twitter.com/jmacmullin)), discussed in [Mobile Couch #45](http://mobilecouch.co/45).

## Rules

1. Collection view must display cells on the pages to either side of the current page.
2. Paging must behave as per the built-in implementation triggered by the paging boolean.
3. Must be a pure collection view. No additional scroll views or custom views are allowed.
4. Code is allowed, but cannot be a hack.

## Solution

Scrollview content insets, as found in iOS 7 and up, allow for content to appear outside of the content area (so it can appear underneath translucent bars, but not be blocked by them), but don't affect the built-in paging code: page size is still considered to be the same as the frame of the collection view.

My solution is to use content insets to adjust the page size, and reimplement a very simple paging mechanism (with the built in version turned off). The benefit of this solution is that it can be applied to anything that uses a scrollview where you want paging and a preview of content on other pages: paging controllers, collection views, table views, etc.

My opinion is that this should be the default behaviour of paging: that the page size is affected by the content insets. The existing implementation is useless as it causes content to be inaccessible. I plan to file a radar, and will update this file with a link once completed.

## Released as Public Domain

This is a simple solution to a long-term problem. I claim no copyright on it, but also take no liability for any consequence of using it, nor do I offer any support for issues you come across.
