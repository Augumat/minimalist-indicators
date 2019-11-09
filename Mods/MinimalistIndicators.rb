class AnimatedBitmap
  #####MODDED
  def aSetBitmap(bitmap)
    @bitmap.aSetBitmap(bitmap)
  end
  #####/MODDED
end
class GifBitmap
  #####MODDED
  def aSetBitmap(bitmap)
    @gifbitmaps[@currentIndex] = bitmap
  end
  #####/MODDED
end

class PokemonDataBox < SpriteWrapper
  #####MODDED

  # Layout;
  ################################
  # type1 type2 # 0 atk # 1 def #
  #            # 2 spa # 3 spd #
  #           # 4 acc # 5 eva #
  #          # 6 crt # 7 spe #
  ###########################

  def miGetStatLevel(statCode)
    case statCode
      when 0
        stat = PBStats::ATTACK
      when 1
        stat = PBStats::DEFENSE
      when 2
        stat = PBStats::SPATK
      when 3
        stat = PBStats::SPEED
      when 4
        stat = PBStats::ACCURACY
      when 5
        stat = PBStats::EVASION
      when 6 # crits are weird, so return based on crit-related effects
        return -6 if @battler.pbOpposingSide.effects[PBEffects::LuckyChant] > 0
        return  6 if @battler.effects[PBEffects::LaserFocus]
        return  1 if @battler.effects[PBEffects::FocusEnergy]
        return  0
      when 7
        stat = PBStats::SPEED
    end
    # fall through and return the correct stage
    return @battler.stages[stat]
  end

  def miDisplayStats
    # stub
  end

  def miDisplayTypes
    miTypeRes = AnimatedBitmap.new(_INTL("Data/Mods/MinimalistIndicatorsTypes"))
    miIsFoe = ((@battler.index == 1) || (@battler.index == 3))
    # grab the types of the battlers (also handle Illusion case)
    if isConst?(@battler.ability, PBAbilities, :ILLUSION) & @battler.effects[PBEffects::Illusion]
      miType1 = @battler.effects[PBEffects::Illusion].type1
      miType2 = @battler.effects[PBEffects::Illusion].type2
    else
      miType1 = @battler.type1
      miType2 = @battler.type2
    end
    # define the rect in miTypeRes that corresponds to the found type
    miPrimaryType   = Rect.new(0, miType1*4, 30, 4)
    miSecondaryType = Rect.new(0, miType2*4, 30, 4)
    # compute the offset needed based on whether the current databox is a foe or the player
    miOffset = (miIsFoe) ? 84 : 14
    # display the primary type in the leftmost position
    self.bitmap.blt(@spritebaseX + miOffset, 2, miTypeRes.bitmap, miPrimaryType)
    # if applicable also display the secondary type in the next position
    if miType1 != miType2
      self.bitmap.blt(@spritebaseX + miOffset + 32, 2, miTypeRes.bitmap, miSecondaryType)
    end
  end

  #####/MODDED

  def refresh
    self.bitmap.clear
    return if !@battler.pokemon
    self.bitmap.blt(0,0,@databox.bitmap,Rect.new(0,0,@databox.width,@databox.height))
    base=PokeBattle_SceneConstants::BOXTEXTBASECOLOR
    shadow=PokeBattle_SceneConstants::BOXTEXTSHADOWCOLOR
    pokename=@battler.name
    pbSetSystemFont(self.bitmap)
    textpos=[
       [pokename,@spritebaseX+8,6,false,base,shadow]
    ]
    genderX=self.bitmap.text_size(pokename).width
    genderX+=@spritebaseX+14
    if @battler.gender==0 # Male
      textpos.push([_INTL("♂"),genderX,6,false,Color.new(48,96,216),shadow])
    elsif @battler.gender==1 # Female
      textpos.push([_INTL("♀"),genderX,6,false,Color.new(248,88,40),shadow])
    end
    pbDrawTextPositions(self.bitmap,textpos)


    pbSetSmallFont(self.bitmap)
    textpos=[
       [_INTL("Lv{1}",@battler.level),@spritebaseX+202,8,true,base,shadow]
    ]


    if @showhp
      hpstring=_ISPRINTF("{1: 2d}/{2: 2d}",self.hp,@battler.totalhp)
      textpos.push([hpstring,@spritebaseX+188,48,true,base,shadow])
    end
    pbDrawTextPositions(self.bitmap,textpos)


    imagepos=[]
    if @battler.pokemon.isShiny?
      shinyX=206
      shinyX=2 if (@battler.index&1)==0 # If player's Pokémon
      imagepos.push(["Graphics/Pictures/shiny.png",@spritebaseX+shinyX,36,0,0,-1,-1])
    end


    megaY=34
    megaY=50 if (@battler.index&1)==0 # If player's Pokémon
    megaX=8
    megaX=12 if (@battler.index&1)==0 # If player's Pokémon
    if @battler.isMega? && @battler.item==606 && $game_switches[457] ==  true
      imagepos.push(["Graphics/Pictures/battlePulseEvoBox.png",@spritebaseX+megaX,megaY,0,0,-1,-1])
    elsif @battler.isMega?
      imagepos.push(["Graphics/Pictures/battleMegaEvoBox.png",@spritebaseX+megaX,megaY,0,0,-1,-1])
    elsif @battler.isUltra? # Maybe temporary until new icon
      imagepos.push(["Graphics/Pictures/battleMegaEvoBox.png",@spritebaseX+megaX,megaY,0,0,-1,-1])
    end
    if @battler.owned && (@battler.index&1)==1
      imagepos.push(["Graphics/Pictures/battleBoxOwned.png",@spritebaseX+8,36,0,0,-1,-1])
    end
    pbDrawImagePositions(self.bitmap,imagepos)
    if @battler.status>0
      self.bitmap.blt(@spritebaseX+24,36,@statuses.bitmap,
         Rect.new(0,(@battler.status-1)*16,44,16))
    end


    hpGaugeSize=PokeBattle_SceneConstants::HPGAUGESIZE
    hpgauge=@battler.totalhp==0 ? 0 : (self.hp*hpGaugeSize/@battler.totalhp)
    hpgauge=2 if hpgauge==0 && self.hp>0
    hpzone=0
    hpzone=1 if self.hp<=(@battler.totalhp/2).floor
    hpzone=2 if self.hp<=(@battler.totalhp/4).floor
    hpcolors=[
       PokeBattle_SceneConstants::HPCOLORGREENDARK,
       PokeBattle_SceneConstants::HPCOLORGREEN,
       PokeBattle_SceneConstants::HPCOLORYELLOWDARK,
       PokeBattle_SceneConstants::HPCOLORYELLOW,
       PokeBattle_SceneConstants::HPCOLORREDDARK,
       PokeBattle_SceneConstants::HPCOLORRED
    ]
    # fill with black (shows what the HP used to be)
    hpGaugeX=PokeBattle_SceneConstants::HPGAUGE_X
    hpGaugeY=PokeBattle_SceneConstants::HPGAUGE_Y
    if @animatingHP && self.hp>0
      self.bitmap.fill_rect(@spritebaseX+hpGaugeX,hpGaugeY,
         @starthp*hpGaugeSize/@battler.totalhp,6,Color.new(0,0,0))
    end
    # fill with HP color
    self.bitmap.fill_rect(@spritebaseX+hpGaugeX,hpGaugeY,hpgauge,2,hpcolors[hpzone*2])
    self.bitmap.fill_rect(@spritebaseX+hpGaugeX,hpGaugeY+2,hpgauge,4,hpcolors[hpzone*2+1])


    if @showexp
      # fill with EXP color
      expGaugeX=PokeBattle_SceneConstants::EXPGAUGE_X
      expGaugeY=PokeBattle_SceneConstants::EXPGAUGE_Y
      self.bitmap.fill_rect(@spritebaseX+expGaugeX,expGaugeY,self.exp,2,
         PokeBattle_SceneConstants::EXPCOLORSHADOW)
      self.bitmap.fill_rect(@spritebaseX+expGaugeX,expGaugeY+2,self.exp,2,
         PokeBattle_SceneConstants::EXPCOLORBASE)
    end

    #####MODDED

    miDisplayStats # display the stat stages of the battlers
    miDisplayTypes # display the types of the battlers

    #####/MODDED
  end
end

# vibe check (for version)
if !(getversion[0..1] == "18")
  Kernel.pbMessage("VIBE CHECK")
  Kernel.pbMessage("YOU FAILED")
  exit
end
