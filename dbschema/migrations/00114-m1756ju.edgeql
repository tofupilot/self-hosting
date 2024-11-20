CREATE MIGRATION m1756junvktnrldjgnepvxm3ic5ncry66sxb2sfi3wd7g7m2tm5pkq
    ONTO m1c7bhoqn5oaafpxrx57vnzb2up5pd5hp3jaanwb2diwvt2g4ehfva
{
  ALTER TYPE default::User {
      CREATE MULTI LINK primitives := (.<user[IS default::Primitive]);
  };
};
