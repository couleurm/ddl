# ddl
(Re-)Direct download links (that are up to date) to most portable windows programs available on [Scoop](https://scoop.sh)

here's how it's generated:

1. get all existing scoop buckets names
2. generate a HTML page for each program which does the following when opened:

    3: fetch the bucket repo's JSON file's download link

    4: redirects to the link

    5: 1000ms cooldown for it to start

    5: `history.back()`
    
    6: if it was opened in a new tab, `window.close()`

If you're familiar with scoop package names you can just do http://couleurm.github.io/ddl/curl and magic! 

If you're familiar with scoop package names you can just do http://couleurm.github.io/ddl/curl and magic! (though it's intended to be used in hyperlinks with `ref="_blank"`)