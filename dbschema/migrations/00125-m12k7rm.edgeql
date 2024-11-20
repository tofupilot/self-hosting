CREATE MIGRATION m12k7rmog2ndxysm3co7ay5x3zimz7bpl3t34xkgkqftdldlobwcbq
    ONTO m1r4y6ncylyk4o6wo64yaleimim3c5wy2genc73bgjvvuel2hctdba
{
  ALTER TYPE default::Primitive {
      CREATE PROPERTY archivedAt: std::datetime;
  };
};
