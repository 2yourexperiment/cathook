
#include "../../xorstring.hpp"

/*
 * aimbot.cpp
 *
 *  Created on: Jun 5, 2017
 *      Author: nullifiedcat
 */

#include "aimbot.hpp"
#include "../../common.h"

namespace ac { namespace aimbot {

static CatVar enabled(CV_SWITCH, XStr("ac_aimbot"), XStr("0"), XStr("Detect Aimbot"), XStr("Is not recommended"));
static CatVar detect_angle(CV_FLOAT, XStr("ac_aimbot_angle"), XStr("30"), XStr("Aimbot Angle"));
static CatVar detections_warning(CV_INT, XStr("ac_aimbot_detections"), XStr("3"), XStr("Min detections to warn"));

ac_data data_table[32];

void ResetEverything() {
	memset(&data_table, 0, sizeof(ac_data) * 32);
}

void ResetPlayer(int idx) {
	memset(&data_table[idx - 1], 0, sizeof(ac_data));
}

void Init() {
	ResetEverything();
}

void Update(CachedEntity* player) {
	if (not enabled) return;
	auto& data = data_table[player->m_IDX - 1];
	if (data.check_timer) {
		data.check_timer--;
		if (!data.check_timer) {
			auto& angles = angles::data(player);
			float deviation = angles.deviation(2);
			if (deviation > float(detect_angle)) {
				//logging::Info(XStr("[ac] %d deviation %.2f #%d"), player->m_IDX, deviation, data.detections);
				if (++data.detections > int(detections_warning)) {
					const char* wp_name = XStr("[unknown]");
					int widx = CE_INT(player, netvar.hActiveWeapon) & 0xFFF;
					if (IDX_GOOD(widx)) {
						CachedEntity* weapon = ENTITY(widx);
						wp_name = weapon->InternalEntity()->GetClientClass()->GetName();
						/*logging::Info(XStr("%d"), weapon->m_IDX);
						logging::Info(XStr("%s"), );
						IClientEntity* e_weapon = RAW_ENT(weapon);
						if (CE_GOOD(weapon)) {
							const char* wname = vfunc<const char*(*)(IClientEntity*)>(e_weapon, 398, 0)(e_weapon);
							if (wname) wp_name = wname;
						}*/
					}
					hacks::shared::anticheat::Accuse(player->m_IDX, XStr("Aimbot"), format(XStr("Weapon: "), wp_name, XStr(" | Deviation: "), deviation, XStr("° | "), data.detections));
				}
			}
		}
	}
}

void Event(KeyValues* event) {
	if (not enabled) return;
	if (!strcmp(event->GetName(), XStr("player_death")) || !strcmp(event->GetName(), XStr("player_hurt"))) {
		int attacker = event->GetInt(XStr("attacker"));
		int victim = event->GetInt(XStr("userid"));
		int eid = g_IEngine->GetPlayerForUserID(attacker);
		int vid = g_IEngine->GetPlayerForUserID(victim);
		if (eid > 0 && eid < 33) {
			CachedEntity* victim = ENTITY(vid);
			CachedEntity* attacker = ENTITY(eid);
			if (victim->m_vecOrigin.DistTo(attacker->m_vecOrigin) > 250) {
				data_table[eid - 1].check_timer = 1;
				data_table[eid - 1].last_weapon = event->GetInt(XStr("weaponid"));
			}
		}
	}
}

}}
