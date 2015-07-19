(function () {
    "use strict";

    // these are micro-optimizations, as such have wide scope
    var uconsole = document.getElementById("Console");
    var ucalc = document.getElementById("LED1");
	var ufirst = document.getElementById("first");
    var usecond = document.getElementById("second");
    var uthird = document.getElementById("third");
    var ufourth = document.getElementById("fourth");
    var cache = null; // saves first solution
    var undo = new Array(); // implements undo
    var istate = null; // implements clear
    var tequals = false; // indicates equals has been pressed
    var tnumber = false; // indicates number has just been pressed

    // initialize only once
    window.addEventListener("load", function load(event) {
        window.removeEventListener("load", load, false);
        handlersOn();
        initCalc();
        enable();
        ucalc.value = "Calculator";
        istate = new calcstate();
    }, false);

    // all of the event handlers
    function handlersOn() {
        handlerOn("ButtonSolv1", "click", calculate1Click);
        handlerOn("ButtonSolvAll", "click", calculateAllClick);
        handlerOn("Select1", "change", selectChanged);
        handlerOn("Select2", "change", selectChanged);
        handlerOn("Select3", "change", selectChanged);
        handlerOn("Select4", "change", selectChanged);
        handlerOn("ButtonR19", "click", randomize19);
        handlerOn("ButtonR124", "click", randomize124);
        handlerOn("plus", "click", calcmany);
        handlerOn("minus", "click", calcmany);
        handlerOn("times", "click", calcmany);
        handlerOn("divide", "click", calcmany);
        handlerOn("openp", "click", calcmany);
        handlerOn("closep", "click", calcmany);
        handlerOn("clear", "click", calcclear);
        handlerOn("clearE", "click", calcundo);
        handlerOn("first", "click", calconce);
        handlerOn("second", "click", calconce);
        handlerOn("third", "click", calconce);
        handlerOn("fourth", "click", calconce);
        handlerOn("equals", "click", calcequ);
    }

    // load the numbers into the calculator
    function initCalc() {
        var vals = [document.getElementById("Select1").selectedIndex + 1,
                    document.getElementById("Select2").selectedIndex + 1,
                    document.getElementById("Select3").selectedIndex + 1,
                    document.getElementById("Select4").selectedIndex + 1].sort(function cval(a, b) { return (a - b); });
        
        ufirst.setAttribute("value", vals[0]);
        usecond.setAttribute("value", vals[1]);
        uthird.setAttribute("value", vals[2]);
        ufourth.setAttribute("value", vals[3]);
    }

    // calculator clear button returns to initial state
    function calcclear() {
        calcSetstate(istate);
        undo.length = 0;
    }

    // calculator clear-entry is an undo 
    function calcundo() {
        if (undo.length > 0) calcSetstate(undo.pop());
    }

    // calculator button that can be pressed infinite times
    function calcmany(e) {
        if (tequals) return false;
        if (undo.length == 0) ucalc.value = "";
        addundo();
        ucalc.value += e.srcElement.value;
        tnumber = false;
        return true;
    }

    // calculator once button for the numbers
    function calconce(e) {
        if (!tnumber) {
            if (calcmany(e)) {
                e.srcElement.disabled = true;
                e.srcElement.classList.add("disabled");
                tnumber = true;
            }
        }
    }

    // constructor for calculator state
    function calcstate() {
        this.display = ucalc.value;
        this.first = ufirst.disabled;
        this.second = usecond.disabled;
        this.third = uthird.disabled;
        this.fourth = ufourth.disabled;
        this.equals = tequals;
        this.number = tnumber;
    }

    // sets caclulator state from saved
    function calcSetstate(state) {
        ucalc.value = state.display;
        numberSetstate(ufirst,state.first);
        numberSetstate(usecond, state.second);
        numberSetstate(uthird, state.third);
        numberSetstate(ufourth, state.fourth);
        tequals = state.equals;
        tnumber = state.number;
    }

    // helper for setting state
    function numberSetstate(number, disabled) {
        number.disabled = disabled;
        if (disabled) number.classList.add("disabled"); else number.classList.remove("disabled");
    }

    // click event for equals
    function calcequ() {
        if (tequals || undo.length == 0) return;
        var result;
        try {
            eval("result=" + ucalc.value);
        }
        catch (e)
        {
            result = "#Err";
        }
        addundo();
        ucalc.value += " = " + result;
        tequals = true;
    }

    // helper for undo
    function addundo() {
        undo.push(new calcstate());
    }

    // handle random 1 thru 9 request
    function randomize19() {
        randomize(1, 9);
    }

    // handle random 1 thru 24 request
    function randomize124() {
        randomize(1, 24);
    }

    // randomize to values that have a solution by trial and error
    function randomize(low, high) {
        cache = null;
        do {
            var vals = [urand(low, high), urand(low, high), urand(low, high), urand(low, high)];
            cache = calculateAll(true, true, null, null, null, null, null, null, null, null, vals);
            if (cache != null) {
                document.getElementById("Select1").selectedIndex = vals[0] - 1;
                document.getElementById("Select2").selectedIndex = vals[1] - 1;
                document.getElementById("Select3").selectedIndex = vals[2] - 1;
                document.getElementById("Select4").selectedIndex = vals[3] - 1;
                selectreset();
            }
        } while (cache == null);
    }

    // reset calculator
    function resetcalc() {
        initCalc();
        calcclear();
    }

    // reset due to randomizer
    function selectreset() {
        console("", true);
        resetcalc();
    }

    // reset due to manual change
    function selectChanged() {
        cache = null;
        selectreset();
    }

    // helper routine to add event handler
    function handlerOn(idname, etype, handler) {
        document.getElementById(idname).addEventListener(etype, handler, false)
    }

    // don't want anything active until whole page is loaded
    function enable() {
        enableByTag("input");
        enableByTag("select");
        //enableByTag("textarea");
    }

    // helper to enable controls
    function enableByTag(tagname) {
        var nodeset = document.getElementsByTagName(tagname);
        for (var i = 0; i < nodeset.length; i++) {
            nodeset[i].removeAttribute("disabled");
        }
    }

    // click handler for one-solution button
    function calculate1Click() {
        calculateClick(true);
    }

    //click handler for all-solution button
    function calculateAllClick() {
        calculateClick(false);
    }

    // dispatcher for click handlers
    function calculateClick(oneonly) {
        if (cache == null) {
            cache = calculateAll(oneonly);
        }
        else {
            calculateAll(oneonly, false, cache.x, cache.y, cache.z, cache.w, cache.i, cache.j, cache.k, cache.h);
        }
    }

    // handles all calculation situations via optional args with defaults
    function calculateAll(stopafterone, suppress, x0, y0, z0, w0, i0, j0, k0, h0, args) {
        var finish = (!stopafterone);
        var display = (!suppress);
        if (!x0) x0 = 0;
        if (!y0) y0 = 0;
        if (!z0) z0 = 0;
        if (!w0) w0 = 0;
        if (!i0) i0 = 0;
        if (!j0) j0 = 0;
        if (!k0) k0 = 0;
        if (!h0) h0 = 0;
        var first = true;
        var ops = ["+", "-", "/", "*"];
        if (!args) args = [document.getElementById("Select1").selectedIndex + 1,
                    document.getElementById("Select2").selectedIndex + 1,
                    document.getElementById("Select3").selectedIndex + 1,
                    document.getElementById("Select4").selectedIndex + 1];

        for (var x = x0; x < args.length; x++) {
            for (var i = i0; i < ops.length; i++) {
                for (var y = y0; y < args.length; y++) {
                    if (y != x) {
                        for (var j = j0; j < ops.length; j++) {
                            for (var z = z0; z < args.length; z++) {
                                if (z != y && z != x) {
                                    for (var k = k0; k < ops.length; k++) {
                                        for (var w = w0; w < args.length; w++) {
                                            if (w != z && w != y && w != x) {
                                                var toeval = ["((" + args[x] + ops[i] + args[y] + ")" + ops[j] + args[z] + ")" + ops[k] + args[w],
                                                                "(" + args[x] + ops[i] + args[y] + ")" + ops[j] + "(" + args[z] + ops[k] + args[w] + ")",
                                                                "(" + args[x] + ops[i] + "(" + args[y] + ops[j] + args[z] + "))" + ops[k] + args[w]]

                                                for (var h = h0; h < toeval.length; h++) {
                                                    var result = 0;
                                                    eval("result=" + toeval[h]);
                                                    if (result == 24) {
                                                        if (display) console(toeval[h] + " = 24", first);
                                                        if (!finish) return JSON.parse( '{' +
                                                                                          '"x" : ' + x + ', "y" :' + y + ', "z" : ' + z + ', "w" :' + w + ',' +
                                                                                          '"i" : ' + i + ', "j" :' + j + ', "k" : ' + k + ', "h" :' + h +
                                                                                        '}');
                                                        first = false;
                                                    }
                                                }
                                                h0 = 0;
                                            }
                                        }
                                        w0 = 0;
                                    }
                                    k0 = 0;
                                }
                            }
                            z0 = 0;
                        }
                        j0 = 0;
                    }
                }
                y0 = 0;
            }
            i0 = 0;
        }
        if (display) {
            if (first) console("No solutions", true); else console("No more solutions", false);
        }
        return null;
    }

    // helper for solution output (also used for trace/debug)
    function console(msg, clear) {
        if (!clear) {
            if (uconsole.innerHTML.indexOf(msg) == -1) {
                if (uconsole.innerHTML.length > 0) uconsole.innerHTML += "<br/>";
                uconsole.innerHTML += msg;
            }
        }
        else
            uconsole.innerHTML = msg;
    }

    // helper for random integers on an inclusive range
    function urand(low, high) {
        return Math.floor((Math.random()*high)+low);
    }
})();