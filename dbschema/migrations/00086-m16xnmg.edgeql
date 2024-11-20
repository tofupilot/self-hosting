CREATE MIGRATION m16xnmgia5flbx3kgrmq5oyyt4k462jze5rii7oq2v2da2rr5tckwa
    ONTO m1wa6o37ggzqpcypyy3cgw5cygezxd3yajgr5vmt3ivprs7jlwoa7q
{
  ALTER SCALAR TYPE default::PrimitiveNamespace EXTENDING enum<Requirement, Design, Plan, Action, Asset, Defect>;
};
