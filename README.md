# Kletba Strahdova: Reloaded – český překlad

Český překlad Obsidian vaultu [Curse of Strahd: Reloaded](https://github.com/DragnaCarta/Curse-of-Strahd-Reloaded)
od DragnaCarty – průvodce pro Pány jeskyně ke kampani *Curse of Strahd* (D&D 5e).

Jde o soukromý fanouškovský překlad pro vlastní potřebu. Originál je dílem DragnaCarty a vychází
z materiálů Wizards of the Coast; nešiřte ho dál.

## Co je přeloženo

| Část | Stav |
| --- | --- |
| Dějství III (shrnutí, oblouky J, K, L, M, O, P, Q) | přeloženo |
| Shrnutí dějství IV | přeloženo |
| Oblouky R, S, T, U (Dějství IV) | rozpracováno (části v `.preklad/`) |
| Epilog, přílohy (Jantarové střepy, Bestiář, Slovníček, Cizí postavy) | zatím v angličtině |
| Úvod, kapitoly 1–3, Dějství I a II | zatím v angličtině (mimo rozsah) |

## Jak číst barvy (Obsidian)

Vault používá CSS snippet `publish` (zapnutý v `.obsidian/appearance.json`; ručně: Nastavení →
Vzhled → CSS snippety → *publish*). V tmavém motivu pak platí:

- **Rámeček se žlutooranžovým okrajem** (`<div class="description">`) = text, který PJ
  **čte nahlas** hráčům – popisy míst a scén i přímá řeč postav v nich.
- **Žlutý tučný text** = odkaz na statistiky nestvůry či NPC (např. vlkodlak (**werewolf**))
  nebo zvýrazněný pojem.
- Barevné rámečky (callouty) = pomůcky pro PJ: *lore* (pozadí), *combat* (boj), *info*,
  *profile* (profil postavy), *item* (předmět), *warning*.

Přímá řeč mimo rámečky je jen v uvozovkách „…“ – je to vodítko pro PJ, co postava
řekne, ne text k doslovnému předčítání.

## Navigace

Vault se otevírá s panelem **Osnova** (Outline) vpravo – stejně jako „On this page“ na webu
originálu ukazuje kapitoly a podkapitoly právě otevřené poznámky; kliknutím na položku skočíte
na dané místo. Pokud panel zmizí: paleta příkazů (Ctrl/Cmd+P) → *Outline: Show outline*
(*Osnova: Zobrazit osnovu*) a panel přetáhněte do pravého postranního panelu.

## Konvence

- Názvy souborů zůstávají anglicky, takže odkazy mezi poznámkami fungují beze změn.
  Nadpisy jsou přeložené a odkazy na ně (`[[Poznámka#Nadpis]]`) přepisuje skript.
- Pravidlové pojmy D&D (kouzla, nestvůry, předměty, stavy, dovednosti) a celé statistiky
  nestvůr zůstávají anglicky, aby šly dohledat v příručkách.
- Všechny termíny a jména jsou v [GLOSAR.md](GLOSAR.md).

## Nástroje (Ruby)

Překlad probíhá po částech; skripty v `tools/` hlídají, aby se nerozbila struktura vaultu.

```sh
# 1. rozdělit anglické poznámky na části (statistiky se odloží stranou)
ruby tools/split.rb <anglický_vault> <pracovní_složka> "Act III - The Broken Land/Arc J - The Stolen Gem.md" …

# 2. přeložit každou NNN.en.md do NNN.cs.md (ručně / s pomocí AI)

# 3. zkontrolovat strukturu (nadpisy, callouty, tabulky, odkazy, obrázky, statistiky)
ruby tools/join.rb <vault> <pracovní_složka> --check

# 4. složit přeložené poznámky zpět do vaultu
ruby tools/join.rb <vault> <pracovní_složka>

# 5. přepsat kotvy odkazů na české nadpisy a doplnit české popisky odkazů
ruby tools/fix_links.rb <vault> <pracovní_složka>
```

`tools/titles.tsv` obsahuje české názvy poznámek, které se zobrazují jako popisky odkazů.
