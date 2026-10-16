# Instructions for translation agents (EN → CS, Curse of Strahd Reloaded)

You are one of several agents translating an Obsidian vault for a D&D 5e "Curse of Strahd"
campaign from English into Czech, in parallel. Consistency between agents matters as much as
quality. Follow these rules exactly.

## Files

- Work dir: `/tmp/claude-0/-home-user/806e6b8a-98e7-5edc-8803-5c8daa05d4de/scratchpad/work`
  (below: `$W`). Each note has a folder with chunks `NNN.en.md`. You write the translation of
  each assigned chunk to `NNN.cs.md` in the same folder (Write tool, whole chunk at once).
- Only write the `.cs.md` files you were assigned, plus your own notes file
  `$W/_terms/<your batch name>.md`. Never edit other files (not the vault, not GLOSAR.md,
  not other agents' chunks, not the `.en.md` sources, not `statblocks/`).
- **Read first, completely:** `/home/user/kletba-strahda/GLOSAR.md` (binding glossary + rules).
- **Style reference (read before you start):** finished translations
  `$W/Act_III_The_Broken_Land_Arc_J_The_Stolen_Gem/008.cs.md` (with its `008.en.md`) and
  `$W/Act_III_The_Broken_Land_Arc_K_The_Fallen_Abbey/004.cs.md`. Match their tone, terms and
  formatting conventions.

## Workflow per chunk

1. Read the whole `NNN.en.md` (it may be long; read all of it).
2. Write the complete Czech translation to `NNN.cs.md`. Translate everything, skip nothing,
   do not summarise, do not add notes of your own.
3. Validate: `ruby /home/user/kletba-strahda/tools/join.rb /home/user/kletba-strahda $W --check | grep '!'`
   Lines mentioning your files mean a structural mismatch — fix them. (Ignore lines about
   other agents' files. Never run join.rb without `--check`.)
4. Proofread your Czech for grammar (v/ve, z/ze, declension, gender agreement of past tense,
   typos, missing spaces) and fix it.

## Structure that must stay identical (the checker compares it)

- Every heading line: same count, same level (`#`, `##`…), same order. Translate heading text,
  but keep area codes like `J1a.`, `R3b.`, `P11d.` exactly.
- Callouts: `> [!type]+`/`-` type and +/- unchanged; translate the title. Keep `>` prefixes on
  every line inside callouts, including blank `>` lines.
- Tables: same number of rows and columns; keep alignment rows (`|:---:|`) as is.
- `<!--STATBLOCK:NNN-->` placeholders: copy exactly, same place. (Stat blocks stay English.)
- `![[image.png]]` embeds: copy exactly.
- Wikilinks `[[Target#Heading|Label]]`: never change `Target#Heading` (keep it English,
  byte-for-byte). Translate only the label after `|`. Leave label-less links label-less
  (`[[Arc J - The Stolen Gem]]` stays as is — a script adds Czech labels later). Inside
  tables the separator is `\|` — keep it.
- Block ids (`^someid`) and footnotes (`[^1]`) unchanged.
- HTML: keep all tags/attributes (`<div class="description">`, `<p>`, `<br>`, `<span class="credit">`,
  `<strong>`, `<em>`, `<hr>`…); translate only the text between tags.
- `<span class="citation">…</span>`: copy verbatim in English (references to the English book).
- Keep blank-line structure roughly as in the source; don't merge or split paragraphs.

## Language rules (summary; GLOSAR.md is binding)

- Prose fully Czech; gothic, dark, literary tone for read-aloud text (`<div class="description">`).
- DM is addressed in 2nd person plural ("Přečtěte:", "Pokud hráči…"). "DM" → "PJ".
- D&D rules terms that are lookup names stay English: spells (*fireball*), monsters/stat-block
  names, standard magic items (*potion of healing*), conditions (frightened, prone…), abilities and
  skills (Wisdom (Insight)), damage types (radiant, necrotic…), stat-block feature names
  (***false appearance***). Ordinary game vocabulary is Czech: ověření Wisdom (Perception) se DC 15,
  záchranný hod na Constitution se DC 14, výhoda/nevýhoda, HP, hod na útok, iniciativa, kolo, tah,
  akce, bonusová akce, reakce, dlouhý/krátký odpočinek, úroveň (6. úroveň), pozice kouzla, trik.
  Dice: `2d6` (not k6). Distances: "30 stop". Numbers: "2 000 XP", "25 %".
- Bold monster references in prose: Czech word + English stat-block name in parentheses:
  `vlkodlak (**werewolf**)`, `druidové Lesního lidu (**druids**)`. If the English bold name is a
  proper name of a unique creature, keep it bold as is. In combat tables keep English names.
- Combat callouts: "Boj – …", **Úroveň boje**: Mírný/Bolestivý/Krvavý/Brutální/Drtivý/Tíživý,
  **Očekávaná úroveň postav**, **Očekávaná ztráta HP:** 25 %, **Spojenci:**, ### **Nepřátelé:**,
  ### **Vyvážení:**, | |3 hráči | 4 hráči | 5 hráčů | 6 hráčů |, | Počet hráčů | Úprava |.
- NPC profiles: **Profil: X**, **Pro hraní role**, ***Vyznění.***, ***Emoce.***, ***Motivace.***,
  ***Inspirace.*** ("Při hraní X čerpejte z postav …" — pop-culture titles stay English),
  **O postavě**, ***Tvář.*** ("Před světem je… Pro ty, jimž důvěřuje, je… V hloubi duše…"),
  ***Morálka.***, ***Vztahy.***
- `***Milestone.***` → `***Milník.***`; image credit line:
  `<span class="credit">„Title in Czech“ – autor: Caleb Cleveland. Podpořte ho na <a href="…">Patreonu!</a></span>`
- Custom (homebrew) magic items: Czech name + English in parentheses; item callout title
  `**Czech Name (English Name)**`; rarity line e.g. `_Zázračný předmět, vzácný (rare wondrous item)_`.
- Names: keep as in English except the Czech-ised ones in GLOSAR.md (Ilja, Taťána, Vladimír,
  Zorja, Kretjana, Anastrasja …; Slavic "y" as a glide → "j"). Female surnames are not
  feminised/declined (lady Fiona Wachter, Ludmilla Vilisevic); male names decline (Strahda,
  Van Richtena, Rahadina). Places/factions/artifacts strictly per GLOSAR.md
  (hrad Ravenloft, Jantarový chrám, Svatý symbol Havraního rodu, Sluneční meč, Strahdův foliant,
  Ikona Ravenloftu, Srdce žalu, Řád stříbrného draka, Strážci pera, Temné mocnosti …).
- Strahd speaks with cold, archaic elegance ("praví", "neboť", formal "vy"); servants and
  commoners speak naturally. Czech quotes „…“ and ‚…‘; dash " – ".
- Rooms of Castle Ravenloft and other area names in prose: translate (Velký vstup, Audienční síň,
  Jídelní síň, Královská síň, Síň kostí …); anything inside citation spans stays English.

## New terms

When you have to coin a Czech name for a recurring proper noun, item, place or title that is
not in GLOSAR.md, use it consistently and record it as a line `English | Czech` in
`$W/_terms/<your batch name>.md`. Check that file of yours before coining again.

## When done

Reply with: chunks completed, the result of the final `--check` for your files, the list of new
terms you coined, and any source anomalies (broken links, typos in the English) you noticed.
