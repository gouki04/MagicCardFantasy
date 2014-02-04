local skill_ = {}

-- 技能的类型
skill_.type = {
	attack = 1,
	magic = 2,
	defend = 3,
	heal = 4,
	assist = 5,
}

-- 技能的动画
skill_.anim = {
	none = 0,
	fire = 1,
	ice = 2,
    poison = 3,
    electric = 4,
    dodge = 5,
}

skill_[1] = {
	file = 'app.model.skill.Skill_ge_dang',
	name = '格挡',
	type = skill_.type.defend,
	anim = skill_.anim.none,
}

skill_[2] = {
	file = 'app.model.skill.skill_shan_bi',
	name = '闪避',
	type = skill_.type.defend,
	anim = skill_.anim.dodge,
}

skill_[3] = {
	file = 'app.model.skill.skill_bao_ji',
	name = '暴击',
	type = skill_.type.attack,
	anim = skill_.anim.none,
}

skill_[4] = {
	file = 'app.model.skill.skill_bei_ci',
	name = '背刺',
	type = skill_.type.attack,
	anim = skill_.anim.none,
}

skill_[5] = {
	file = 'app.model.skill.skill_huo_qiu',
	name = '火球',
	type = skill_.type.magic,
	anim = skill_.anim.fire,
}

skill_[6] = {
	file = 'app.model.skill.skill_lie_yan_feng_bao',
	name = '烈焰风暴',
	type = skill_.type.magic,
	anim = skill_.anim.fire,
}

skill_[7] = {
	file = 'app.model.skill.skill_huo_qiang',
	name = '火墙',
	type = skill_.type.magic,
	anim = skill_.anim.fire,
}

skill_[8] = {
	file = 'app.model.skill.skill_sheng_guang',
	name = '圣光',
	type = skill_.type.attack,
	anim = skill_.anim.none,
}

skill_[9] = {
	file = 'app.model.skill.skill_wang_guo_zhi_li',
	name = '王国之力',
	type = skill_.type.assist,
	anim = skill_.anim.none,
}

return skill_