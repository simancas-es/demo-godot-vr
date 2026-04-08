REM #NO_TRANSLATE and msginit --no-translator --input=base_template.pot --locale=de
REM Sometimes there is an incorrectly duplicated "" inside the base_template... just eliminate
msguniq -o base_template_unique.pot base_template.pot
msgmerge -vU en.po base_template_unique.pot
msgmerge -vU es.po base_template_unique.pot
msgmerge -vU de.po base_template_unique.pot
msgmerge -vU fr.po base_template_unique.pot