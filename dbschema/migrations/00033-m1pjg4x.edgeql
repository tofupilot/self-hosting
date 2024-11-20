CREATE MIGRATION m1pjg4xmyjbc3hxh4u77dc7f5m55gncozyu5yjwi3j6v4v3iojypwa
    ONTO m14wod7hmefn66ekwudxwbyaeclqrlx4wmmmhaqth24pvuwh2csu3q
{
  ALTER TYPE activity::UserVisitActivity RENAME TO activity::UserVisit;
};
