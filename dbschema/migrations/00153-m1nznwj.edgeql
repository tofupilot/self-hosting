CREATE MIGRATION m1nznwjmlan54s43mrklfgcl2l2y7lqv4wgp2ebpyt366tdcmatwiq
    ONTO m1samaqfgxss7osdvl3cfbtcbsnmnqvzdbu5afbut2lso3zccrf44q
{
  ALTER TYPE default::Asset RENAME TO default::Unit;
  ALTER SCALAR TYPE default::PrimitiveNamespace EXTENDING enum<Requirement, Design, Procedure, Action, Asset, Unit, Defect>;
};
