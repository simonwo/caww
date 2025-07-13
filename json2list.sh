#!/bin/bash
set -euxo pipefail
IFS=$'\n\t'

cat <<-END
	<!DOCTYPE html>
	<html lang="en">
		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
			<style type="text/css">html, body { margin: 0; padding: 0; background: none; font-family: sans-serif; } ul { padding-left: 2ch; margin: 0;}</style>
		</head>
		<body>
			<ul>
				$(jq -r '.[] | "<li><a target=\"_top\" href=\"\(.url)\">\(.name)</a></li>"' $1)
			</ul>
		</body>
	</html>
END
