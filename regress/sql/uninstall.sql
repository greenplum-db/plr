\! gppkg -q --all | sed -n '/^plr-/s|.*|plr|p'
\! echo '############# SEPARATOR LINE ###########'
-- start_ignore
\! gppkg -r 'plr-*'
-- end_ignore
\! gppkg -q --all | sed -n '/^plr-/s|.*|plr|p'
