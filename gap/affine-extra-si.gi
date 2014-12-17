
if not TestPackageAvailability("SingularInterface") = fail then
    LoadPackage("SingularInterface");  
fi;


######################################################################
# Computes a minimal presentation of the affine semigroup a 
# REQUERIMENTS: SingularInterface
######################################################################
InstallOtherMethod(MinimalPresentationOfAffineSemigroup,
	"Computes the minimal presentation of an affine semigroup",
	[IsAffineSemigroup],3,
	function( a )
    local i, p, rel, rgb, msg, pol, ed,  sdegree, monomial, candidates, mp,
		R,id, ie, vars, mingen, exps, bintopair, dim, zero, ls;

	Info(InfoNumSgps,2,"Using SingularInterface to compute minimal presentations.");
    if not(IsAffineSemigroup(a)) then
        Error("The argument must be an affine semigroup");
    fi;
    
    ls:=GeneratorsOfAffineSemigroup(a);

            
    ##computes the s degree of a pol in the semigroup ideal 
    sdegree:=function(r) 
        local exp;
        exp:=_SI_Plistintvec(SI_leadexp(SI_leadmonom(r)));
        return exp*msg;
    end;
    
    #tanslates binomial to pair of exponents
    bintopair:=function(p)
        local m1,m2, d1, d2;
        m1:=p[1];#SI_leadmonom(p);
        m2:=p[2];#m1-p;
        d1:=_SI_Plistintvec(SI_leadexp(m1)); 
        d2:=_SI_Plistintvec(SI_leadexp(m2));
        return [d1{[1..ed]},d2{[1..ed]}];
    end;
    
    msg:=ls; #for now we do not check minimality of the generators
    ed:=Length(msg);
    if ed=0 then 
        return [];
    fi;
    zero:=List([1..ed],_->0);
    dim:=Length(ls[1]);
    vars:=List([1..ed+dim],i->Concatenation("x",String(i)));
    R:=SI_ring(0,vars,[["wp",List(msg, m->Sum(m))],["dp",dim]]);
    p:=List([1..ed], i->SI_var(R,i)-
            SI_monomial(R,SI_intvec(Concatenation(zero,msg[i]))));
    id:=SI_ideal(p);
    Info(InfoNumSgps,2,"Eliminating the variables ", Product(List([1..dim],i-> SI_var(R,ed+i))),
         " from the ideal ", id);
    ie:= SI_eliminate(id, Product(List([1..dim],i-> SI_var(R,ed+i)) ));	
    Info(InfoNumSgps,2,"and we obtain ",ie);
    vars:=vars{[1..ed]};
    R:=SI_ring(0,vars,[["wp",List(msg, m->Sum(m))]]);
    p:=[];
    for i in [1..SI_ncols(ie)] do
        exps:=bintopair(ie[i]);
        Add( p, SI_monomial(R,SI_intvec(exps[1]))-
             SI_monomial(R,SI_intvec(exps[2]))); 
    od;
    id:=SI_ideal(p);
    mingen:=SI_minbase(id);
    return Set([1..SI_ncols(mingen)],i->bintopair(mingen[i]));
end);

