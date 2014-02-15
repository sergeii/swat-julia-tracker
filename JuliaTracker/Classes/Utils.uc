class Utils extends Core.Object;

/**
 * Copyright (c) 2014 Sergei Khoroshilov <kh.sergei@gmail.com>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/**
 * List of objective class names
 * @type array<string>
 */
var array<string> ObjectiveClass;

/**
 * List of procedure class names
 * @type array<string>
 */
var array<string> ProcedureClass;

/**
 * List of ammo class names
 * @type array<string>
 */
var array<string> AmmoClass;

/**
 * Return the last 8 characters of a md5 hash computed of given Key, Port and unix timestamp values
 * 
 * @param   string Key
 * @param   string Port
 * @param   string Unixtime
 * @return  string
 */
static function string ComputeHash(coerce string Key, coerce string Port, coerce string Unixtime)
{
    return Right(ComputeMD5Checksum(Key $ Port $ Unixtime), 8);
}

/**
 * Encode a string by replacing it with its corresponding position in array Array
 * 
 * @param   string String
 * @param   array<string> Array 
 * @return  string
 */
static function string EncodeString(coerce string String, array<string> Array)
{
    return string(class'Utils.ArrayUtils'.static.Search(Array, String, true));
}

/**
 * Join non empty keys with Delimiter
 * 
 * @param   string Key1
 * @param   string Key2 (optional)
 * @param   string Key3 (optional)
 * @param   string Key4 (optional)
 * @param   string Key5 (optional)
 * @return  string
 */
static function string FormatDelimitedKey(string Key1, optional string Key2, optional string Key3, optional string Key4, optional string Key5)
{
    local int i;
    local array<string> Keys;

    Keys[0] = Key1;
    Keys[1] = Key2;
    Keys[2] = Key3;
    Keys[3] = Key4;
    Keys[4] = Key5;

    // Remove empty keys
    for (i = Keys.Length-1; i >= 0; i--)
    {
        if (Keys[i] == "")
        {
            Keys.Remove(i, 1);
        }
    }

    return class'Utils.ArrayUtils'.static.Join(Keys, class'Extension'.const.KEY_DELIMITER);
}

/**
 * Enclose non empty key components in square brackets
 * 
 * @param   string Key1
 * @param   string Key2 (optional)
 * @param   string Key3 (optional)
 * @param   string Key4 (optional)
 * @param   string Key5 (optional)
 * @return  string
 */
static function string FormatArrayKey(string Key1, optional string Key2, optional string Key3, optional string Key4, optional string Key5)
{
    local int i;
    local array<string> Keys;

    Keys[0] = Key2;
    Keys[1] = Key3;
    Keys[2] = Key4;
    Keys[3] = Key5;

    for (i = Keys.Length-1; i >= 0; i--)
    {
        // Remove empty components
        if (Keys[i] == "")
        {
            Keys.Remove(i, 1);
        }
        // Otherwise enclose them in a pair of square brackets
        else
        {
            Keys[i] = "[" $ Keys[i] $ "]";
        }
    }

    return Key1 $ class'Utils.ArrayUtils'.static.Join(Keys, "");
}

defaultproperties
{
    ProcedureClass(0)="Procedure_ArrestIncapacitatedSuspects";          // Bonus points for incapacitating a suspect (12,5/total each)
    ProcedureClass(1)="Procedure_ArrestUnIncapacitatedSuspects";        // Bonus points for arresting a suspect (25/1=25/total each)
    ProcedureClass(2)="Procedure_CompleteMission";                      // Bonus points for all objectives completed (40)
    ProcedureClass(3)="Procedure_EvacuateDownedOfficers";               // Penalty points for not reporting a downed officer (??)
    ProcedureClass(4)="Procedure_KillSuspects";                         // No bonus points for killing suspects
    ProcedureClass(5)="Procedure_NoCiviliansInjured";                   // Bonus points for not letting civilians to be injured (5 for all)
    ProcedureClass(6)="Procedure_NoHostageIncapacitated";               // Penalty points for incapacitating a civilian (-5 each)
    ProcedureClass(7)="Procedure_NoHostageKilled";                      // Penalty points for killing a civilian (-15 each)
    ProcedureClass(8)="Procedure_NoOfficerIncapacitated";               // Penalty points for killing an officer (-15 each)
    ProcedureClass(9)="Procedure_NoOfficerInjured";                     // Penalty points for injuring an officer (-5 each)
    ProcedureClass(10)="Procedure_NoOfficersDown";                      // Bonus points for staying alive (10/total each officer)
    ProcedureClass(11)="Procedure_NoSuspectsNeutralized";               // Bonus points for not letting suspects to be killed (5 for all)
    ProcedureClass(12)="Procedure_NoUnauthorizedUseOfDeadlyForce";      // Penalty points for using unauthorized deadly force (-10 each)
    ProcedureClass(13)="Procedure_NoUnauthorizedUseOfForce";            // Penalty points for using unauthorized force (-5 each)
    ProcedureClass(14)="Procedure_PlayerUninjured";                     // Bonus points for staying uninjured (5/total each)
    ProcedureClass(15)="Procedure_PreventEvidenceDestruction";          // Penalty points for an evidence destruction (-5 each)
    ProcedureClass(16)="Procedure_PreventSuspectEscape";                // Penalty points for a suspect escape (-5 each)
    ProcedureClass(17)="Procedure_ReportCharactersToTOC";               // Bonus points for TOC reports (5/total each)
    ProcedureClass(18)="Procedure_SecureAllWeapons";                    // Bonus points for securing all weapons (5/total each)

    ObjectiveClass(0)="Arrest_Jennings";
    ObjectiveClass(1)="Custom_NoCiviliansInjured";
    ObjectiveClass(2)="Custom_NoOfficersInjured";
    ObjectiveClass(3)="Custom_NoOfficersKilled";
    ObjectiveClass(4)="Custom_NoSuspectsKilled";
    ObjectiveClass(5)="Custom_PlayerUninjured";
    ObjectiveClass(6)="Custom_Timed";
    ObjectiveClass(7)="Disable_Bombs";
    ObjectiveClass(8)="Disable_Office_Bombs";
    ObjectiveClass(9)="Investigate_Laundromat";
    ObjectiveClass(10)="Neutralize_Alice";
    ObjectiveClass(11)="Neutralize_All_Enemies";
    ObjectiveClass(12)="Neutralize_Arias";
    ObjectiveClass(13)="Neutralize_CultLeader";
    ObjectiveClass(14)="Neutralize_Georgiev";
    ObjectiveClass(15)="Neutralize_Grover";
    ObjectiveClass(16)="Neutralize_GunBroker";
    ObjectiveClass(17)="Neutralize_Jimenez";
    ObjectiveClass(18)="Neutralize_Killer";
    ObjectiveClass(19)="Neutralize_Kiril";
    ObjectiveClass(20)="Neutralize_Koshka";
    ObjectiveClass(21)="Neutralize_Kruse";
    ObjectiveClass(22)="Neutralize_Norman";
    ObjectiveClass(23)="Neutralize_TerrorLeader";
    ObjectiveClass(24)="Neutralize_Todor";
    ObjectiveClass(25)="Rescue_Adams";
    ObjectiveClass(26)="Rescue_All_Hostages";
    ObjectiveClass(27)="Rescue_Altman";
    ObjectiveClass(28)="Rescue_Baccus";
    ObjectiveClass(29)="Rescue_Bettencourt";
    ObjectiveClass(30)="Rescue_Bogard";
    ObjectiveClass(31)="Rescue_CEO";
    ObjectiveClass(32)="Rescue_Diplomat";
    ObjectiveClass(33)="Rescue_Fillinger";
    ObjectiveClass(34)="Rescue_Kline";
    ObjectiveClass(35)="Rescue_Macarthur";
    ObjectiveClass(36)="Rescue_Rosenstein";
    ObjectiveClass(37)="Rescue_Sterling";
    ObjectiveClass(38)="Rescue_Victims";
    ObjectiveClass(39)="Rescue_Walsh";
    ObjectiveClass(40)="Rescue_Wilkins";
    ObjectiveClass(41)="Rescue_Winston";
    ObjectiveClass(42)="Secure_Briefcase";
    ObjectiveClass(43)="Secure_Weapon";

    AmmoClass(0)="None";
    AmmoClass(1)="M4Super90SGAmmo";
    AmmoClass(2)="M4Super90SGSabotAmmo";
    AmmoClass(3)="NovaPumpSGAmmo";
    AmmoClass(4)="NovaPumpSGSabotAmmo";
    AmmoClass(5)="LessLethalAmmo";
    AmmoClass(6)="CSBallLauncherAmmo";
    AmmoClass(7)="M4A1MG_JHP";
    AmmoClass(8)="M4A1MG_FMJ";
    AmmoClass(9)="AK47MG_FMJ";
    AmmoClass(10)="AK47MG_JHP";
    AmmoClass(11)="G36kMG_FMJ";
    AmmoClass(12)="G36kMG_JHP";
    AmmoClass(13)="UZISMG_FMJ";
    AmmoClass(14)="UZISMG_JHP";
    AmmoClass(15)="MP5SMG_JHP";
    AmmoClass(16)="MP5SMG_FMJ";
    AmmoClass(17)="UMP45SMG_FMJ";
    AmmoClass(18)="UMP45SMG_JHP";
    AmmoClass(19)="ColtM1911HG_JHP";
    AmmoClass(20)="ColtM1911HG_FMJ";
    AmmoClass(21)="Glock9mmHG_JHP";
    AmmoClass(22)="Glock9mmHG_FMJ";
    AmmoClass(23)="PythonRevolverHG_FMJ";
    AmmoClass(24)="PythonRevolverHG_JHP";
    AmmoClass(25)="TaserAmmo";
    AmmoClass(26)="VIPPistolAmmo_FMJ";
    AmmoClass(27)="ColtAR_FMJ";
    AmmoClass(28)="HK69GL_StingerGrenadeAmmo";
    AmmoClass(29)="HK69GL_FlashbangGrenadeAmmo";
    AmmoClass(30)="HK69GL_CSGasGrenadeAmmo";
    AmmoClass(31)="HK69GL_TripleBatonAmmo";
    AmmoClass(32)="SAWMG_JHP";
    AmmoClass(33)="SAWMG_FMJ";
    AmmoClass(34)="FNP90SMG_FMJ";
    AmmoClass(35)="FNP90SMG_JHP";
    AmmoClass(36)="DEHG_FMJ";
    AmmoClass(37)="DEHG_JHP";
    AmmoClass(38)="TEC9SMG_FMJ";
}

/* vim: set ft=java: */