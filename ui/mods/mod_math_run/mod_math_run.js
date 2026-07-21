var ModMathRun = function (_parent) {
    this.BrotherNames = [];
    MSUBackendConnection.call(this);
    this.mModID = "mod_math_run";
    this.mNameSpace = "ModMathRun";
}


ModMathRun.SQHandle = null;

ModMathRun.queryBrotherNames = function (_callback)
{
    if (ModMathRun.SQHandle === null)
    {
        return;
    }

    SQ.call(ModMathRun.SQHandle, 'onQueryBrotherNames', [], function (_names)
    {
        ModMathRun.BrotherNames = _names || [];
        if (_callback !== undefined)
        {
            _callback();
        }
    });
};
ModMathRun.updateBrotherNames = function ()
{
    var BrotherNamesString = MSU.getSettingValue("mod_math_run", "BrotherNames");
    MSU.printData(BrotherNamesString);
    ModMathRun.BrotherNames = BrotherNamesString ? BrotherNamesString.split("|") : [];
};

ModMathRun.prototype = Object.create(MSUBackendConnection.prototype);
Object.defineProperty(ModMathRun.prototype, 'constructor', {
    value: ModMathRun,
    enumerable: false,
    writable: true
});

ModMathRun.prototype.onConnection = function (_handle)
{
    MSUBackendConnection.prototype.onConnection.call(this, _handle);
    ModMathRun.SQHandle = this.mSQHandle;
    ModMathRun.queryBrotherNames();
    // ModMathRun.updateBrotherNames();
};

var ModMathRun_createHireDialogDIV = WorldTownScreenHireDialogModule.prototype.createDIV;
WorldTownScreenHireDialogModule.prototype.createDIV = function (_parentDiv)
{

    // ModMathRun.BrotherNames = BrotherNamesArray;
    ModMathRun_createHireDialogDIV.call(this, _parentDiv);

    var vanillaUpdateDetailsPanel = this.updateDetailsPanel;
    this.updateDetailsPanel = function (_element)
    {
        vanillaUpdateDetailsPanel.call(this, _element);
        // console.log("ModMathRun: updateDetailsPanel called with element:", JSON.stringify(_element));
        // console.log("ModMathRun: BrotherNames:", JSON.stringify(ModMathRun.BrotherNames));
        if (_element !== null)
        {
            var data = _element.data('entry');
            // logConsole("ModMathRun: BrotherNames:", JSON.stringify(data));
            // logConsole("ModMathRun: BrotherNames:", JSON.stringify(ModMathRun.BrotherNames));
            ModMathRun.updateBrotherNames();
            if (data !== null && data !== undefined && (
                typeof data.Name === 'string' &&
                ModMathRun.BrotherNames.indexOf(data.Name) === -1
            )
                &&
                (typeof data.InitialMoneyCost !== 'number' || data.InitialMoneyCost % 15 !== 0))
            {
                this.mDetailsPanel.HireButton.enableButton(false);
            }
        }
    };

    ModMathRun.queryBrotherNames(function ()
    {
        if (this.mSelectedEntry !== null)
        {
            this.updateDetailsPanel(this.mSelectedEntry);
        }
    }.bind(this));
};

registerScreen("ModMathRun", new ModMathRun());
