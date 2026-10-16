# Rozpracovaný překlad

Pracovní složka nástrojů `tools/split.rb` a `tools/join.rb`: každá poznámka má podsložku
s anglickými částmi `NNN.en.md`, hotovými českými částmi `NNN.cs.md` a odloženými
statistikami ve `statblocks/`. Hotové poznámky se skládají příkazy:

    ruby tools/join.rb . .preklad --check
    ruby tools/join.rb . .preklad
    ruby tools/fix_links.rb . .preklad

`_INSTRUCTIONS.md` a `_terms/` jsou pokyny a zvolené termíny z paralelního překladu.
