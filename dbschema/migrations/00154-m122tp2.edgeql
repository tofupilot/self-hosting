CREATE MIGRATION m122tp2pkmhjfu6apjabndrjtljowtj6agq6d6fj4e7ugv6d7kieoa
    ONTO m1nznwjmlan54s43mrklfgcl2l2y7lqv4wgp2ebpyt366tdcmatwiq
{
  ALTER SCALAR TYPE default::PrimitiveNamespace EXTENDING enum<Requirement, Design, Procedure, Action, Unit, Defect>;
};
