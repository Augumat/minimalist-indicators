# Layout;
#######################################
# gender type1 type2 # 0 atk # 1 def #
#                   # 2 spa # 3 spd #
#                  # 4 acc # 5 eva #
#                 # 6 crt # 7 spe #
##################################

class AnimatedBitmap
  def aSetBitmap(bitmap)
    @bitmap.aSetBitmap(bitmap)
  end
end

class GifBitmap
  def aSetBitmap(bitmap)
    @gifbitmaps[@currentIndex] = bitmap
  end
end









class PokemonDataBox < SpriteWrapper

  # [Base Boxes]
  # 0) right large / right top
  # 1) left bottom
  # 2) right bottom
  # 3) left top
  #   0) normal
  #   1) mega
  #   2) ultra
  #   3) primal
  #   4) pulse
  @@miBase = [[],[],[],[]]

  # [Types]
  # 0-19) all types 0-19 (not gonna list em here)
  @@miType = []

  # [Stat Changes]
  # 0) stat outline for icon window
  # 1-7) stat levels 1-6
  @@miStatLevelPositive = []
  @@miStatLevelNegative = []
  # 0) attack
  # 1) defense
  # 2) special attack
  # 3) special defense
  # 4) accuracy
  # 5) evasion
  # 6) crit
  # 7) speed
  @@miStatIcon = []

  # [Misc]
  @@miShiny = []
  @@miCaught = []
  # 0) male
  # 1) female
  # 2) genderless
  @@miGender = []
  # 0) badly poisoned
  # 1) sleep
  # 2) poison
  # 3) burn
  # 4) paralysis
  # 5) freeze
  @@miEffect = []

  # flag for whether or not the player is currently in a double battle
  @@miDoubles = false








  

  # One-time initialization of the mod
  def miInit
    # load the resource sprite sheets and grab what is needed from them
    miBaseSheet = AnimatedBitmap.new(_INTL("Data/Mods/MinimalistIndicatorsBase"))
    miTypeSheet = AnimatedBitmap.new(_INTL("Data/Mods/MinimalistIndicatorsType"))
    miStatSheet = AnimatedBitmap.new(_INTL("Data/Mods/MinimalistIndicatorsStat"))
    miMiscSheet = AnimatedBitmap.new(_INTL("Data/Mods/MinimalistIndicatorsMisc"))
    # load base boxes
    for i in 0..4
      # from 272/86 270/62 270/62
      @@miBase[0][i] = Bitmap.new(272, 86).blt(0, 0, miBaseSheet.bitmap, Rect.new(i*272, 0,   i*272+272, 86 ))
      @@miBase[1][i] = Bitmap.new(270, 62).blt(0, 0, miBaseSheet.bitmap, Rect.new(i*272, 86,  i*272+270, 148))
      @@miBase[2][i] = Bitmap.new(270, 62).blt(0, 0, miBaseSheet.bitmap, Rect.new(i*272, 148, i*272+270, 210))
      @@miBase[3][i] = Bitmap.new(270, 62).blt(0, 0, miBaseSheet.bitmap, Rect.new(i*272, 86,  i*272+270, 148))
    end
    # load types
    for i in 0..19
      @@miType[i] = Bitmap.new(30, 10).blt(0, 0, miTypeSheet.bitmap, Rect.new(0, i*10, 30, i*10+10))
    end
    # load stat icons
    for i in 0..7
      @@miStatIcon[i] = Bitmap.new(12, 12).blt(0, 0, miStatSheet.bitmap, Rect.new(i*12, 0, i*12+12, 12))
    end
    # load stat bars
    @@miStatLevelPositive[0] = Bitmap.new(12, 12).blt(0, 0, miStatSheet.bitmap, Rect.new(0, 12, 12, 24))
    @@miStatLevelNegative[0] = Bitmap.new(12, 12).blt(0, 0, miStatSheet.bitmap, Rect.new(0, 24, 12, 36))
    for i in 1..7
      @@miStatLevelPositive[i] = Bitmap.new(2, 12).blt(0, 0, miStatSheet.bitmap, Rect.new(i*2+10, 12, i*2+12, 24))
      @@miStatLevelNegative[i] = Bitmap.new(2, 12).blt(0, 0, miStatSheet.bitmap, Rect.new(i*2+10, 24, i*2+12, 36))
    end
    # load status effects
    for i in 0..5
      @@miEffect[i] = Bitmap.new(40, 10).blt(0, 0, miMiscSheet.bitmap, Rect.new(0, i*10, 40, i*10+10))
    end
    # load icons
    @@miShiny[0]  = Bitmap.new(10, 10).blt(0, 0, miMiscSheet.bitmap, Rect.new(40, 0,  50, 10))
    @@miCaught[0] = Bitmap.new(10, 10).blt(0, 0, miMiscSheet.bitmap, Rect.new(40, 10, 50, 20))
    # load genders
    @@miGender[0] = Bitmap.new(6, 6).blt(0, 0, miMiscSheet.bitmap, Rect.new(50, 0,  56, 6 ))
    @@miGender[1] = Bitmap.new(6, 6).blt(0, 0, miMiscSheet.bitmap, Rect.new(50, 6,  56, 12))
    @@miGender[2] = Bitmap.new(6, 6).blt(0, 0, miMiscSheet.bitmap, Rect.new(50, 12, 56, 18))
    # by default the scene is not recognized as a double battle
    @@miDoubles = false
    # turn on Ready flag so this initialization doesn't trigger again
    @miReady = true
  end

  # Displays the base data box depending on the "temporary enhancement" status of a pokemon
  def miDisplayBaseBox
    # determine the appropriate base box (checked in order of likelihood)
    miWhichBox = 0
    if !(@battler.isMega? || @battler.isUltra?)
      # default
    elsif @battler.isMega?
      # mega
      miWhichBox = 1
    elsif @battler.isUltra?
      # ultra
      miWhichBox = 2
    elsif @battler.isMega? && (@battler.item == 636 || @battler.item == 637)
      # primal
      miWhichBox = 3
    elsif @battler.isMega? && (@battler.item == 606 && $game_switches[457])
      # pulse
      miWhichBox = 4
    else
      # not in an established category, so error out
      Kernel.pbMessage("Unknown enhancement state, exiting...")
      exit
    end
    # determine the base box orientation and set it
    @databox.aSetBitmap(@@miBase[@battler.index][miWhichBox])
    # account for offsets based on battler index
    miTemp = Bitmap.new(1, 1)
    case @battler.index
      when 0
        @spriteX = 250
        if @@miDoubles
          @spriteY = 164
        else
          @spriteY = 198
        end
        miTemp = Bitmap.new(@spritebaseX + 272, 86)
      when 1
        @spriteX = 0
        if @@miDoubles
          @spriteY = 2
        else
          @spriteY = 44
        end
        miTemp = Bitmap.new(@spritebaseX + 270, 62)
      when 2
        @spriteX = 256
        @spriteY = 224
        miTemp = Bitmap.new(@spritebaseX + 270, 62)
      when 3
        @spriteX = -4
        @spriteY = 62
        miTemp = Bitmap.new(@spritebaseX + 270, 62)
    end
    # replace the base box
    miTemp.blt(0, 0, self.bitmap, self.bitmap.rect)
    self.bitmap = miTemp
  end

  # Displays the battler's types
  def miDisplayTypes
    # grab the types of the battlers (also handle Illusion case)
    if isConst?(@battler.ability, PBAbilities, :ILLUSION) && @battler.effects[PBEffects::Illusion]
      miType1 = @battler.effects[PBEffects::Illusion].type1
      miType2 = @battler.effects[PBEffects::Illusion].type2
    else
      miType1 = @battler.type1
      miType2 = @battler.type2
    end
    # display the primary type in the leftmost position
    case @battler.index
      when 0
        self.bitmap.blt(40,  2, @@miType[miType1], Rect.new(0, 0, 30, 10))
      when 1
        self.bitmap.blt(168, 2, @@miType[miType1], Rect.new(0, 0, 30, 10))
      when 2
        self.bitmap.blt(40,  2, @@miType[miType1], Rect.new(0, 0, 30, 10))
      when 3
        self.bitmap.blt(168, 2, @@miType[miType1], Rect.new(0, 0, 30, 10))
    end
    # display the secondary type in the rightmost position
    case @battler.index
      when 0
        self.bitmap.blt(72,  2, @@miType[miType2], Rect.new(0, 0, 30, 10))
      when 1
        self.bitmap.blt(200, 2, @@miType[miType2], Rect.new(0, 0, 30, 10))
      when 2
        self.bitmap.blt(72,  2, @@miType[miType2], Rect.new(0, 0, 30, 10))
      when 3
        self.bitmap.blt(200, 2, @@miType[miType2], Rect.new(0, 0, 30, 10))
    end
    # if the pokemon only has one type, join the two icons so it's one long bar instead
    if miType1 == miType2
      case @battler.index
        when 0
          self.bitmap.blt(70,  2, @@miType[miType2], Rect.new(14, 0, 16, 10))
        when 1
          self.bitmap.blt(198, 2, @@miType[miType2], Rect.new(14, 0, 16, 10))
        when 2
          self.bitmap.blt(70,  2, @@miType[miType2], Rect.new(14, 0, 16, 10))
        when 3
          self.bitmap.blt(198, 2, @@miType[miType2], Rect.new(14, 0, 16, 10))
      end
    end
  end

  # Displays the battler's gender
  def miDisplayGender
    case @battler.index
      when 0
        self.bitmap.blt(110, 4, @@miGender[@battler.gender], Rect.new(0, 0, 6, 6))
      when 1
        self.bitmap.blt(154, 4, @@miGender[@battler.gender], Rect.new(0, 0, 6, 6))
      when 2
        self.bitmap.blt(110, 4, @@miGender[@battler.gender], Rect.new(0, 0, 6, 6))
      when 3
        self.bitmap.blt(154, 4, @@miGender[@battler.gender], Rect.new(0, 0, 6, 6))
    end
    # TODO redo this to accumulate sprite list to feed to
    # pbDrawImagePositions(self.bitmap, <LIST HERE>)
  end

  # Displays whether or not the battler has been previously caught
  def miDisplayCaught
    if @battler.owned
      if @battler.index == 1
        self.bitmap.blt(202, 38, @@miCaught[0], Rect.new(0, 0, 10, 10))
      elsif @battler.index == 3
        self.bitmap.blt(202, 38, @@miCaught[0], Rect.new(0, 0, 10, 10))
      end
    end
    # TODO redo this to accumulate sprite list to feed to
    # pbDrawImagePositions(self.bitmap, <LIST HERE>)
  end

  # Displays whether or not the battler is a shiny variant
  def miDisplayShiny
    # only continue if the pokemon is shiny
    if @battler.pokemon.isShiny?
      # display the shiny icon in the correct place
      case @battler.index
        when 0
          self.bitmap.blt(238, 38, @@miShiny[0], Rect.new(0, 0, 10, 10))
        when 1
          self.bitmap.blt(184, 38, @@miShiny[0], Rect.new(0, 0, 10, 10))
        when 2
          self.bitmap.blt(238, 38, @@miShiny[0], Rect.new(0, 0, 10, 10))
        when 3
          self.bitmap.blt(184, 38, @@miShiny[0], Rect.new(0, 0, 10, 10))
      end
    end
    # TODO redo this to accumulate sprite list to feed to
    # pbDrawImagePositions(self.bitmap, <LIST HERE>)
  end

  # Displays any status effects the pokemon is afflicted with
  def miDisplayEffect
    # check if the battler has a status condition at all
    if @battler.status > 0
      if @battler.status == 2 && @battler.statusCount == 1
        # display badly poisoned
        case @battler.index
          when 0
            self.bitmap.blt(58, 38, @@miEffect[0], Rect.new(0, 0, 40, 10))
          when 1
            self.bitmap.blt(4,  38, @@miEffect[0], Rect.new(0, 0, 40, 10))
          when 2
            self.bitmap.blt(58, 38, @@miEffect[0], Rect.new(0, 0, 40, 10))
          when 3
            self.bitmap.blt(4,  38, @@miEffect[0], Rect.new(0, 0, 40, 10))
        end
      else 
        # display a normal status
        case @battler.index
          when 0
            self.bitmap.blt(58, 38, @@miEffect[@battler.status], Rect.new(0, 0, 40, 10))
          when 1
            self.bitmap.blt(4,  38, @@miEffect[@battler.status], Rect.new(0, 0, 40, 10))
          when 2
            self.bitmap.blt(58, 38, @@miEffect[@battler.status], Rect.new(0, 0, 40, 10))
          when 3
            self.bitmap.blt(4,  38, @@miEffect[@battler.status], Rect.new(0, 0, 40, 10))
        end
      end
    end
  end

  # Displays the xp bar of the current battler
  def miDisplayXP
    if @showexp
      self.bitmap.fill_rect(52, 76, self.exp, 2, PokeBattle_SceneConstants::EXPCOLORSHADOW)
      self.bitmap.fill_rect(52, 78, self.exp, 2, PokeBattle_SceneConstants::EXPCOLORBASE  )
    end
  end

  # Displays the battler's HP bar
  def miDisplayHP
    # determine the length of the bar in its current state
    hpLen = 121
    hpGauge = @battler.totalhp == 0 ? 0 : (hpLen * self.hp / @battler.totalhp)
    hpGauge = 2 if hpGauge == 0 && self.hp > 0
    # determine what color the bar should be displayed as based on the pokemon's current HP
    hpZone = 0
    hpZone = 1 if self.hp <= (@battler.totalhp / 2).floor
    hpZone = 2 if self.hp <= (@battler.totalhp / 4).floor
    hpBlack = Color.new(0,0,0)
    hpColors=[
       PokeBattle_SceneConstants::HPCOLORGREENDARK,
       PokeBattle_SceneConstants::HPCOLORGREEN,
       PokeBattle_SceneConstants::HPCOLORYELLOWDARK,
       PokeBattle_SceneConstants::HPCOLORYELLOW,
       PokeBattle_SceneConstants::HPCOLORREDDARK,
       PokeBattle_SceneConstants::HPCOLORRED
    ]
    # fill trail of hp currently decreasing
    if @animatingHP && self.hp > 0
      case @battler.index
        when 0
          self.bitmap.fill_rect(108, 38, hpLen * @starthp / @battler.totalhp, 10, hpBlack)
        when 1
          self.bitmap.fill_rect(54,  38, hpLen * @starthp / @battler.totalhp, 10, hpBlack)
        when 2
          self.bitmap.fill_rect(108, 38, hpLen * @starthp / @battler.totalhp, 10, hpBlack)
        when 3
          self.bitmap.fill_rect(54,  38, hpLen * @starthp / @battler.totalhp, 10, hpBlack)
      end
    end
    # display existing hp
    case @battler.index
      when 0
        self.bitmap.fill_rect(108, 38, hpGauge, 10, hpColors[hpZone*2]  )
        self.bitmap.fill_rect(108, 40, hpGauge, 6,  hpColors[hpZone*2+1])
      when 1
        self.bitmap.fill_rect(54,  38, hpGauge, 10, hpColors[hpZone*2]  )
        self.bitmap.fill_rect(54,  40, hpGauge, 6,  hpColors[hpZone*2+1])
      when 2
        self.bitmap.fill_rect(108, 38, hpGauge, 10, hpColors[hpZone*2]  )
        self.bitmap.fill_rect(108, 40, hpGauge, 6,  hpColors[hpZone*2+1])
      when 3
        self.bitmap.fill_rect(54,  38, hpGauge, 10, hpColors[hpZone*2]  )
        self.bitmap.fill_rect(54,  40, hpGauge, 6,  hpColors[hpZone*2+1])
    end
  end

  # Helper method for miDisplayStats, draws the specified stat at the specified location
  def miDrawStat(x, y, statCode)
    # grab the current level of the stat of interest
    miLevel = 0
    case statCode
      when 0
        miLevel = @battler.stages[PBStats::ATTACK]
      when 1
        miLevel = @battler.stages[PBStats::DEFENSE]
      when 2
        miLevel = @battler.stages[PBStats::SPATK]
      when 3
        miLevel = @battler.stages[PBStats::SPDEF]
      when 4
        miLevel = @battler.stages[PBStats::ACCURACY]
      when 5
        miLevel = @battler.stages[PBStats::EVASION]
      when 6 # crits are weird, so return based on crit-related effects
        if @battler.pbOpposingSide.effects[PBEffects::LuckyChant] > 0
          miLevel = -6
        elsif @battler.effects[PBEffects::LaserFocus]
          miLevel = 6
        else
          miLevel = @battler.effects[PBEffects::FocusEnergy]
        end
      when 7
        miLevel = @battler.stages[PBStats::SPEED]
    end
    # draw the stat's status (positive or negative) and level
    if miLevel > 0
      self.bitmap.blt(x, y, @@miStatLevelPositive[0], Rect.new(0, 0, 12, 12))
      self.bitmap.blt(x + 14, y, @@miStatLevelPositive[miLevel.abs()], Rect.new(0, 0, 2, 12))
    elsif miLevel < 0
      self.bitmap.blt(x, y, @@miStatLevelNegative[0], Rect.new(0, 0, 12, 12))
      self.bitmap.blt(x + 14, y, @@miStatLevelNegative[miLevel.abs()], Rect.new(0, 0, 2, 12))
    else
      # nothing
    end
    # draw the stat's identifying icon on top
    self.bitmap.blt(x, y, @@miStatIcon[statCode], Rect.new(0, 0, 12, 12))
  end
  # Displays the stat changes of the battler
  def miDisplayStats
    case @battler.index
      when 0
        miDrawStat(4,  4,  0)
        miDrawStat(22, 4,  1)
        miDrawStat(8,  18, 2)
        miDrawStat(26, 18, 3)
        miDrawStat(12, 32, 4)
        miDrawStat(30, 32, 5)
        miDrawStat(16, 46, 6)
        miDrawStat(34, 46, 7)
      when 1
        miDrawStat(232, 4,  0)
        miDrawStat(250, 4,  1)
        miDrawStat(228, 18, 2)
        miDrawStat(246, 18, 3)
        miDrawStat(224, 32, 4)
        miDrawStat(242, 32, 5)
        miDrawStat(220, 46, 6)
        miDrawStat(238, 46, 7)
      when 2
        miDrawStat(4,  4,  0)
        miDrawStat(22, 4,  1)
        miDrawStat(8,  18, 2)
        miDrawStat(26, 18, 3)
        miDrawStat(12, 32, 4)
        miDrawStat(30, 32, 5)
        miDrawStat(16, 46, 6)
        miDrawStat(34, 46, 7)
      when 3
        miDrawStat(232, 4,  0)
        miDrawStat(250, 4,  1)
        miDrawStat(228, 18, 2)
        miDrawStat(246, 18, 3)
        miDrawStat(224, 32, 4)
        miDrawStat(242, 32, 5)
        miDrawStat(220, 46, 6)
        miDrawStat(238, 46, 7)
    end
  end

  # Displays the battler's name, gender, and level
  def miDisplayText
    base = PokeBattle_SceneConstants::BOXTEXTBASECOLOR
    shadow = PokeBattle_SceneConstants::BOXTEXTSHADOWCOLOR
    pbSetSystemFont(self.bitmap)
    textpos = []
    case @battler.index
      when 0
        # display name
        textpos.push([@battler.name, 124, 4, false, base, shadow])
        pbDrawTextPositions(self.bitmap, textpos)
        # display level
        pbSetSmallFont(self.bitmap)
        if !$MKXP
          textX = 82
          if @battler.level < 10
            textX = 82
          elsif @battler.level < 100
            textX = 92
          else
            textX = 102
          end
          textpos = [[_INTL("Lv{1}", @battler.level), textX, 11, true, base, shadow]]
        else
          textX = 82
          if @battler.level < 10
            textX = 82
          elsif @battler.level < 100
            textX = 92
          else
            textX = 102
          end
          textpos = [[_INTL("Lv{1}", @battler.level), textX, 15, true, base, shadow]]
        end
        # display HP
        if @showhp
          hpstring = _ISPRINTF("{1: 2d} /{2: 2d}", self.hp, @battler.totalhp)
          if !$MKXP
            textpos.push([hpstring, 232, 44, true, base, shadow])
          else
            textpos.push([hpstring, 232, 52, true, base, shadow])
          end
        end
      when 1
        # display name
        textpos.push([@battler.name, 20, 4, false, base, shadow])
        pbDrawTextPositions(self.bitmap, textpos)
        # display level
        pbSetSmallFont(self.bitmap)
        if !$MKXP
          textX = 200
          if @battler.level < 10
            textX = 200
          elsif @battler.level < 100
            textX = 210
          else
            textX = 220
          end
          textpos = [[_INTL("Lv{1}", @battler.level), textX, 11, true, base, shadow]]
        else
          textX = 200
          if @battler.level < 10
            textX = 200
          elsif @battler.level < 100
            textX = 210
          else
            textX = 220
          end
          textpos = [[_INTL("Lv{1}", @battler.level), textX, 15, true, base, shadow]]
        end
      when 2
        # display name
        textpos.push([@battler.name, 124, 4, false, base, shadow])
        pbDrawTextPositions(self.bitmap, textpos)
        # display level
        pbSetSmallFont(self.bitmap)
        if !$MKXP
          textX = 82
          if @battler.level < 10
            textX = 82
          elsif @battler.level < 100
            textX = 92
          else
            textX = 102
          end
          textpos = [[_INTL("Lv{1}", @battler.level), textX, 11, true, base, shadow]]
        else
          textX = 82
          if @battler.level < 10
            textX = 82
          elsif @battler.level < 100
            textX = 92
          else
            textX = 102
          end
          textpos = [[_INTL("Lv{1}", @battler.level), textX, 15, true, base, shadow]]
        end
      when 3
        # display name
        textpos.push([@battler.name, 20, 4, false, base, shadow])
        pbDrawTextPositions(self.bitmap, textpos)
        # display level
        pbSetSmallFont(self.bitmap)
        if !$MKXP
          textX = 200
          if @battler.level < 10
            textX = 200
          elsif @battler.level < 100
            textX = 210
          else
            textX = 220
          end
          textpos = [[_INTL("Lv{1}", @battler.level), textX, 11, true, base, shadow]]
        else
          textX = 200
          if @battler.level < 10
            textX = 200
          elsif @battler.level < 100
            textX = 210
          else
            textX = 220
          end
          textpos = [[_INTL("Lv{1}", @battler.level), textX, 15, true, base, shadow]]
        end
    end
    pbDrawTextPositions(self.bitmap, textpos)
  end









  def refresh
    # old code
    self.bitmap.clear
    return if !@battler.pokemon
    self.bitmap.blt(0, 0, @databox.bitmap, Rect.new(0, 0, @databox.width, @databox.height))
    # flag the current fight as a doubles battle if a databox with index 3 or 4 is refreshed
    if !(@@miDoubles) && @battler.index > 1
      @@miDoubles = true
    end
    # runs initialization if it has not been already
    if !(defined?@miReady)
      miInit
    end
    # run through and display each element of the DataBox
    miDisplayBaseBox    # displays whether the battler is normal or temporarily enhanced
    miDisplayTypes      # display the types of the battler
    miDisplayGender     # displays the gender of the battler
    miDisplayCaught     # display whether the battler has already been caught before
    miDisplayShiny      # display whether the battler is shiny
    miDisplayEffect     # displays any status effects the pokemon is inflicted with
    miDisplayHP         # display the hp bar
    miDisplayXP         # display the xp bar if necessary
    miDisplayStats      # display the stat stages of the battler
    miDisplayText       # displays the name, level, and exact hp of the pokemon
  end

end









# vibe check (for version)
if !(getversion[0..1] == "18")
  Kernel.pbMessage("VIBE CHECK")
  Kernel.pbMessage("YOU FAILED")
  Kernel.pbMessage("(You are using an outdated version of Reborn, please disable MinimalistIndicators until it is updated to the current version. Thanks!)")
  exit
end
