CREATE MIGRATION m1zhbmrqcrkb3e7q7n5jt5ia3byavldaiozq3mairizg6lijhkv5ea
    ONTO m1l3pyuqbhhsg3ngdx2rfda27ipemeqh65z3bwyimftqx2od7avdaa
{
  ALTER TYPE default::Upload {
      DROP LINK primitives;
  };
  ALTER TYPE default::Upload {
      CREATE MULTI LINK usedBy := (.<attachments[IS default::Primitive]);
  };
};
