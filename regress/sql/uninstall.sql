\! gppkg -q --all | sed -n '/^plr-[0-9]/s|.*|plr|p'
\! echo '############# SEPARATOR LINE ###########'
-- start_ignore
\! gppkg -r plr
-- end_ignore
\! gppkg -q --all | sed -n '/^plr-[0-9]/s|.*|plr|p'
