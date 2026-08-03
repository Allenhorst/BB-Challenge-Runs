::ModMathRun <- {
	ID = "mod_math_run",
	Name = "ModMathRun",
	Version = "1.0.0",
	// Modern Hooks Object
	MH = null,
	// MSU Object
	Mod = null,
	// JS Connection
	Connection = null,
	BrotherNames = [],
	NamesDelimiter = "|",
	DefaultInitialBrotherNames = "Magnus|Karl|Steinar|Ragnar|Geralt",
	DefaultCostDivider = "15",
}
::ModMathRun.serializeBrotherNamesWithFlag <- function()
{
	local names = this.BrotherNames;
	if (names.len() > 0)
		::World.Flags.set("ModMathRun_BrotherNames", this.stringifyNames(names));
	else ::World.Flags.set("ModMathRun_BrotherNames", this.stringifyNames([]));
}
::ModMathRun.deserializeBrotherNamesWithFlag <- function()
{
	local namesString = ::World.Flags.get("ModMathRun_BrotherNames");

	if (!namesString || namesString == null)
	{
		return;
	}
	local names = this.getNamesAsArrayFromString(namesString);
	this.BrotherNames = names;
}

::ModMathRun.setBrotherNames <- function(_firstBrotherName)
{
	local initialNamesSetting = this.Mod.ModSettings.getSetting("InitialBrotherNames");
	local names = this.getNamesAsArrayFromString(initialNamesSetting.getValue());
	names.insert(0, _firstBrotherName);
	this.BrotherNames = names;
}

::ModMathRun.stringifyNames <- function(_namesAsArray)
{
	if (_namesAsArray.len() == 0)
	{
		return "";
	}

	local resultString = "";
	foreach(name in _namesAsArray){
		resultString += name + this.NamesDelimiter;
	}
	return resultString.slice(0, resultString.len() - 1);
}
::ModMathRun.getNamesAsArrayFromString <- function(_namesString)
{

	if (_namesString == null || _namesString == "")
    {
        return [];
    }
	local result = split(_namesString, this.NamesDelimiter);
	return result;
}

// Instantiate the Modern Hooks object, add MSU as a requirement, and queue after MSU
// https://bbmodding.enduriel.com/docs/modern-hooks/mod-object/
::ModMathRun.MH = ::Hooks.register(::ModMathRun.ID, ::ModMathRun.Version, ::ModMathRun.Name);
::ModMathRun.MH.require("mod_msu");
::ModMathRun.MH.queue(">mod_msu", function(){
	// Instantiate the MSU Object
	// https://github.com/MSUTeam/MSU/wiki/Mod
	::ModMathRun.Mod = ::MSU.Class.Mod(::ModMathRun.ID, ::ModMathRun.Version, ::ModMathRun.Name);

	// Instantiates the JS connection to the file ui/mods/mod_math_run/mod_math_run.js
	local myPanel = ::ModMathRun.Mod.ModSettings.getPanel();
	local generalPage = ::ModMathRun.Mod.ModSettings.addPage("General");
	local initialNamesSetting = generalPage.addStringSetting(
		"InitialBrotherNames",
		::ModMathRun.DefaultInitialBrotherNames,
		"Initial Brother Names"
	);
	initialNamesSetting.setDescription("Names added at the start of a new campaign, separated by the '|' character. Edit this setting before starting the campaign. The starting brother's name is added automatically.");
	generalPage.addDivider("1");
	local costDividerSetting = generalPage.addStringSetting(
		"CostDivider",
		::ModMathRun.DefaultCostDivider,
		"Cost Divider"
	);
	costDividerSetting.setDescription("A positive whole number used for the recruit cost divisibility check. Invalid values fall back to 15.");
	generalPage.addDivider("2");
	local namesSetting = generalPage.addStringSetting("BrotherNames", "", "BrotherNames");
	namesSetting.setDescription("The names used by the current campaign, separated by the '|' character. This is initialized from the starting brother and the Initial Brother Names setting.");
	namesSetting.addAfterChangeCallback(function(_value)
	{
		::ModMathRun.BrotherNames = ::ModMathRun.getNamesAsArrayFromString(this.getValue());
	});
	generalPage.addDivider("3");
	::ModMathRun.Connection = ::new("scripts/mods/msu/js_connection");
	::ModMathRun.Connection.m.ID = ::ModMathRun.Name;
	::ModMathRun.Connection.onQueryBrotherNames <- function()
	{
		return ::ModMathRun.BrotherNames;
	};
	::Hooks.registerJS("ui/mods/mod_math_run/mod_math_run.js");
	::Hooks.registerCSS("ui/mods/mod_math_run/mod_math_run.css");
	::MSU.UI.registerConnection(::ModMathRun.Connection);


	::mods_hookNewObject("ui/global/data_helper", function(o){
		local convertEntityHireInformationToUIData = o.convertEntityHireInformationToUIData;
		o.convertEntityHireInformationToUIData = function(_entity)
		{
			local data = convertEntityHireInformationToUIData(_entity);
			data.Name <- _entity.getNameOnly();
			return data;
		};
	});

	::mods_hookNewObject("states/world_state", function(o){
		local startNewCampaign = o.startNewCampaign;
		o.startNewCampaign = function()
		{
			startNewCampaign();

			local brothers = this.World.getPlayerRoster().getAll();
			if (brothers.len() > 0)
			{
				::ModMathRun.setBrotherNames(brothers[0].getNameOnly());
				local brotherNamesSetting = ::ModMathRun.Mod.ModSettings.getSetting("BrotherNames");
				local namesString = ::ModMathRun.stringifyNames(::ModMathRun.BrotherNames);
				brotherNamesSetting.set(namesString);
			}
		};

		local onDeserialize = o.onDeserialize;
		o.onDeserialize = function(_in)
		{
			onDeserialize(_in);
			::ModMathRun.deserializeBrotherNamesWithFlag();
		};

		local onSerialize = o.onSerialize;
		o.onSerialize = function(_out)
		{
			onSerialize(_out);
			::ModMathRun.serializeBrotherNamesWithFlag();
		};
	});

	::mods_hookNewObject("entity/tactical/player", function(o){
		local onDeserialize = o.onDeserialize;
		o.onDeserialize = function(_in)
		{
			onDeserialize(_in);
			::ModMathRun.deserializeBrotherNamesWithFlag();
		};

		local onSerialize = o.onSerialize;
		o.onSerialize = function(_out)
		{
			onSerialize(_out);
			::ModMathRun.serializeBrotherNamesWithFlag();
		};
	})

	// Includes the 'load' file of your private folder
	// Within this file, you can execute things or load more files (such as hooks)
	// as to better organise your mod, not clutter this file, and load things in order
	// ::include("mod_math_run/load.nut");
});
