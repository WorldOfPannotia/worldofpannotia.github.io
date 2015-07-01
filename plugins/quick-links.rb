module Jekyll
  OPEN_VAR = /(?:\{\{ *)?/
  CLOSE_VAR = /(?:(?: *\| *[-_a-zA-Z0-9]+)* *\}\})?/
  SLUG_SYNTAX = /(?<slug>#{OPEN_VAR}\w+(?:(?:\-|\.)\w+)*#{CLOSE_VAR})/
  FRAGMENT_SYNTAX = /(?: #(?<fragment>#{OPEN_VAR}\w+(?:(?:\-|\.)\w+)*#{CLOSE_VAR}))/
  TITLE_SYNTAX = /(?: (?:"(?<titleText1>[^"]+)"|'(?<titleText2>[^']+)'))?/

  module PannotiaLinkTags
    Syntax = /#{SLUG_SYNTAX}#{TITLE_SYNTAX}#{FRAGMENT_SYNTAX}?/

    class ItemLink
      def initialize(tag_name, markup, tokens)
        if !markup || (markup.strip =~ Syntax).nil? || !(markup.strip =~ Syntax)
          raise SyntaxError.new("Syntax Error in '#{tag_name}' - Valid syntax: '#{tag_name} <slug>', '#{tag_name} <slug> \"link text\"', or '#{tag_name} <slug> \"link text\" \#link-fragment'")
        end

        matches = markup.strip.match(Syntax)
        @item_tag = tag_name
        @item_slug = matches['slug']

        @item_link_text = ''
        if matches['titleText1'] || matches['titleText2']
          if matches['titleText1']
            @item_link_text = matches['titleText1']
          else
            @item_link_text = matches['titleText2']
          end
        end

        @item_link_fragment = ''
        if matches['fragment']
          @item_link_fragment = '#' + matches['fragment']
        end

        case tag_name
        when "artifact_link"
          @item_collection = "artifacts"
        when "base_class_link"
          @item_collection = "base_classes"
        when "cursed_item_link"
          @item_collection = "cursed_items"
        when "domain_link"
          @item_collection = "domains"
        when "epic_class_link"
          @item_collection = "epic_classes"
        when "epic_feat_link"
          @item_collection = "epic_feats"
        when "epic_magic_armor_ability_link", "epic_magic_shield_ability_link"
          @item_collection = "epic_magic_armor_abilities"
        when "epic_magic_weapon_ability_link"
          @item_collection = "epic_magic_weapon_abilities"
        when "epic_prestige_class_link"
          @item_collection = "epic_prestige_classes"
        when "epic_ring_link"
          @item_collection = "epic_rings"
        when "epic_rod_link"
          @item_collection = "epic_rods"
        when "epic_skill_link"
          @item_collection = "epic_skills"
        when "epic_specific_magic_armor_link"
          @item_collection = "epic_specific_magic_armor"
        when "epic_specific_magic_weapon_link"
          @item_collection = "epic_specific_magic_weapons"
        when "epic_spell_link"
          @item_collection = "epic_spells"
        when "epic_staff_link"
          @item_collection = "epic_staffs"
        when "epic_wondrous_item_link"
          @item_collection = "epic_wondrous_items"
        when "feat_link"
          @item_collection = "feats"
        when "magic_armor_ability_link", "magic_shield_ability_link"
          @item_collection = "magic_armor_abilities"
        when "magic_weapon_ability_link"
          @item_collection = "magic_weapon_abilities"
        when "npc_class_link"
          @item_collection = "npc_classes"
        when "plane_link"
          @item_collection = "planes"
        when "power_link"
          @item_collection = "psionic_powers"
        when "prestige_class_link"
          @item_collection = "prestige_classes"
        when "psicrown_link"
          @item_collection = "psicrowns"
        when "psionic_armor_ability_link", "psionic_shield_ability_link"
          @item_collection = "psionic_armor_abilities"
        when "psionic_weapon_ability_link"
          @item_collection = "psionic_weapon_abilities"
        when "race_link"
          @item_collection = "races"
        when "racial_class_link"
          @item_collection = "racial_classes"
        when "ring_link"
          @item_collection = "rings"
        when "rod_link"
          @item_collection = "rods"
        when "skill_link"
          @item_collection = "skills"
        when "specific_magic_armor_link", "specific_magic_shield_link"
          @item_collection = "specific_magic_armor"
        when "specific_magic_weapon_link"
          @item_collection = "specific_magic_weapons"
        when "special_ability_link"
          @item_collection = "special_abilities"
        when "spell_link"
          @item_collection = "spells"
        when "staff_link"
          @item_collection = "staffs"
        when "status_condition_link"
          @item_collection = "status_conditions"
        when "wondrous_item_link"
          @item_collection = "wondrous_items"
        else
          raise SyntaxError.new("Syntax Error in '#{tag_name}' - Unknown link type.")
        end
      end

      def render(context)
        site = context.registers[:site]
        collection = site.collections[@item_collection]

        if collection.nil?
          raise SyntaxError.new("Empty collection: #{@item_collection}")
        end

        partial = Liquid::Template.parse(@item_slug)
        slug = partial.render!(context)

        collection.docs.each do |item|
          if slug == item.basename_without_ext
            if @item_link_text != ''
              title = @item_link_text
            else
              case @item_collection
              when "domains"
                title = item.data["title"] + ' Domain'
              else
                title = item.data["title"]
              end
            end

            case @item_collection
            when 'epic_magic_armor_abilities', 'epic_magic_shield_abilities'
              url = site.config['url'] + "/equipment/epic-magic-items/armor/\#ability--" + slug
            when 'epic_magic_weapon_abilities'
              url = site.config['url'] + "/equipment/epic-magic-items/weapons/\#ability--" + slug
            when 'epic_skills', 'skills'
              url = site.config['url'] + "/game-rules/skills/\#skill--" + slug
            when 'magic_armor_abilities', 'magic_shield_abilities'
              url = site.config['url'] + "/equipment/magic-items/armor/\#ability--" + slug
            when 'magic_weapon_abilities'
              url = site.config['url'] + "/equipment/magic-items/weapons/\#ability--" + slug
            when 'status_conditions'
              url = site.config['url'] + "/game-rules/adventuring/status-conditions/\#condition--" + slug
            when 'special_abilities'
              url = site.config['url'] + "/game-rules/adventuring/special-abilities/\#ability--" + slug
            else
              url = site.config['url'] + item.url + @item_link_fragment
            end
            link_text = "<em>#{title}</em>"

            case @item_collection
            when 'artifacts', 'base_classes', 'domains', 'epic_classes', 'epic_feats', 'epic_prestige_classes', 'epic_rings', 'epic_rods', 'epic_staffs', 'feats', 'npc_classes', 'planes', 'prestige_classes', 'psicrowns', 'races', 'racial_classes', 'rings', 'rods', 'staffs'
              link_text = title
            end

            return <<-MARKUP.strip
              <a href="#{url}" title="#{title}">#{link_text}</a>
            MARKUP
          end
        end

        raise ArgumentError.new <<-eos
Could not find page "#{slug}" in collection "#{@item_collection}" in tag '#{@item_tag}'.

Make sure the page exists and the name is correct.
eos
      end
    end
  end

  module PannotiaEmbedTags
    class ItemEmbed
      Syntax = /^#{SLUG_SYNTAX}$/

      def initialize(tag_name, markup, tokens)
        if !markup || (markup.strip =~ Syntax).nil? || !(markup.strip =~ Syntax)
          raise SyntaxError.new("Syntax Error in '#{tag_name}' - Valid syntax: '#{tag_name} <slug>'")
        end

        matches = markup.strip.match(Syntax)

        @item_tag = tag_name
        @item_slug = matches['slug']

        case tag_name
        when "epic_magic_armor_ability_embed", "epic_magic_shield_ability_embed"
          @item_collection = "epic_magic_armor_abilities"
        when "epic_magic_weapon_ability_embed"
          @item_collection = "epic_magic_weapon_abilities"
        when "epic_skill_embed"
          @item_collection = "epic_skills"
        when "magic_armor_ability_embed", "magic_shield_ability_embed"
          @item_collection = "magic_armor_abilities"
        when "magic_weapon_ability_embed"
          @item_collection = "magic_weapon_abilities"
        when "plane_embed"
          @item_collection = "planes"
        when "skill_embed"
          @item_collection = "skills"
        when "special_ability_embed"
          @item_collection = "special_abilities"
        when "status_condition_embed"
          @item_collection = "status_conditions"
        else
          raise SyntaxError.new("Syntax Error in '#{tag_name}' - Unknown embed type.")
        end
      end

      def liquify(input, context)
        partial = Liquid::Template.parse(input)
        partial.render!(context)
      end

      def render(context)
        site = context.registers[:site]
        collection = site.collections[@item_collection]

        slug = liquify(@item_slug, context)

        collection.docs.each do |item|
          if slug == item.basename_without_ext
            case @item_collection
            when 'epic_skills', 'planes'
              return <<-eos
##### #{item.data["title"]}

#{item.content}
eos

            when 'epic_magic_armor_abilities', 'epic_magic_shield_abilities', 'epic_magic_weapon_abilities', 'magic_armor_abilities', 'magic_shield_abilities', 'magic_weapon_abilities'
              subtext = ""
              subtext_arr = []
              ability = item.data["ability"]

              if ability["aura"] && ability["aura"] != ""
                subtext_arr.push(liquify(ability["aura"], context))
              end
              if ability["casterLevel"]
                subtext_arr.push("CL " + liquify(ability["casterLevel"], context))
              end
              if ability["prerequisites"]
                prereqs = []
                if ability["prerequisites"]["feats"].size > 0
                  prereqs.push(liquify(ability["prerequisites"]["feats"].join(", "), context))
                end
                if ability["prerequisites"]["spells"].size > 0
                  prereqs.push(liquify(ability["prerequisites"]["spells"].join(", "), context))
                end
                if ability["prerequisites"]["special"].size > 0
                  prereqs.push(liquify(ability["prerequisites"]["special"].join(", "), context))
                end
                if prereqs.size > 0
                  subtext_arr.push("_Prerequisites:_ " + prereqs.join(", "))
                end
              end
              if ability["price"]
                subtext_arr.push("Price " + liquify(ability["price"], context))
              end
              if ability["description"]
                description = liquify(ability["description"], context)
              end
              if subtext_arr.size > 0
                subtext = subtext_arr.join("; ")
              end
              return <<-eos
##### #{item.data["title"]} \{\#ability--#{slug}\}

#{description}

#{subtext}
eos

            when 'skills'
              trained = armor_check = check = action = try_again = special = synergy = restriction = untrained = ""
              skill = item.data["skill"]

              if skill["trained_only"]
                trained = "; Trained Only"
              end
              if skill["armor_check_penalty"]
                armor_check = "; Armor Check Penalty"
              end
              if skill["check"] && skill["check"] != ""
                check = "**Check:** " + skill["check"]
              end
              if skill["action"] && skill["action"] != ""
                action = "**Action:** " + skill["action"]
              end
              if skill["try_again"] && skill["try_again"] != ""
                try_again = "**Try Again:** " + skill["try_again"]
              end
              if skill["special"] && skill["special"] != ""
                special = "**Special:** " + skill["special"]
              end
              if skill["synergy"] && skill["synergy"] != ""
                synergy = "**Synergy:**\n\n" + skill["synergy"]
              end
              if skill["restriction"] && skill["restriction"] != ""
                restriction = "**Restriction:** " + skill["restriction"]
              end
              if skill["untrained"] && skill["untrained"] != ""
                untrained = "**Untrained:** " + skill["untrained"]
              end
              return <<-eos
#### #{item.data["title"]} (#{skill["key_ability"]}#{trained}#{armor_check}) \{\#skill--#{slug}\}

#{skill["description"]}

#{check}

#{action}

#{try_again}

#{special}

#{synergy}

#{restriction}

#{untrained}
eos

            when 'special_abilities'
              ability = item.data["ability"]
              types = ""
              if !ability["types"].nil?
                types = " (" + ability["types"].join(" or ") + ")"
              end
              return <<-eos
##### #{item.data["title"]}#{types} \{\#ability--#{slug}\}

#{ability["description"]}
eos

            when 'status_conditions'
              return <<-eos
##### #{item.data["title"]} \{\#condition--#{slug}\}

#{item.data["condition"]["description"]}
eos
            end
          end
        end

"epic_magic_armor_abilities"
"epic_magic_weapon_abilities"
"magic_armor_abilities"
"magic_weapon_abilities"


        raise ArgumentError.new <<-eos
Could not find page "#{slug}" in collection "#{@item_collection}" in tag '#{@item_tag}'.

Make sure the page exists and the name is correct.
eos
      end
    end
  end
end

['artifact', 'base_class', 'cursed_item', 'domain', 'epic_class', 'epic_feat', 'epic_magic_armor_ability', 'epic_magic_shield_ability', 'epic_magic_weapon_ability', 'epic_prestige_class', 'epic_ring', 'epic_rod', 'epic_skill', 'epic_specific_magic_armor', 'epic_specific_magic_weapon', 'epic_spell', 'epic_staff', 'epic_wondrous_item', 'feat', 'magic_armor_ability', 'magic_shield_ability', 'magic_weapon_ability', 'npc_class', 'power', 'prestige_class', 'psicrown', 'psionic_armor_ability', 'psionic_shield_ability', 'psionic_weapon_ability', 'race', 'racial_class', 'ring', 'rod', 'skill', 'special_ability', 'specific_magic_armor', 'specific_magic_shield', 'specific_magic_weapon', 'spell', 'staff', 'status_condition', 'wondrous_item'].each do |tag|
  link = tag + "_link"
  Liquid::Template.register_tag(link, Jekyll::PannotiaLinkTags::ItemLink)
end

['epic_magic_armor_ability', 'epic_magic_shield_ability', 'epic_magic_weapon_ability', 'epic_skill', 'magic_armor_ability', 'magic_shield_ability', 'magic_weapon_ability', 'plane', 'skill', 'special_ability', 'status_condition'].each do |tag|
  embed = tag + "_embed"
  Liquid::Template.register_tag(embed, Jekyll::PannotiaEmbedTags::ItemEmbed)
end