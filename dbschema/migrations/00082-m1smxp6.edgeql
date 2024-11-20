CREATE MIGRATION m1smxp6o2jsexkb4yfkfn6irl6orn3xfimbx2w3kbtdsaadtrfipqq
    ONTO m1hxahbwktbqrdk62rw2wlsntbxmijo7bkqf52oq2zejppm7amre4q
{
  ALTER SCALAR TYPE default::PrimitiveNamespace EXTENDING enum<Product, Requirement, Issue, ActionTemplate, Action, Design, Asset, Plan, Defect>;
};
