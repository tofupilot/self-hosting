CREATE MIGRATION m1u3vmgykhcuioxkp55vydy5p5wvm3zs2wgzsrnolkbo7ihcpsoc6a
    ONTO m16fu4xhf234iiczceln6poxc6eitfmcs2hiiu2o7vjycesy5qrrzq
{
  ALTER TYPE default::Project {
      DROP PROPERTY externalLink1;
      DROP PROPERTY externalLink2;
      DROP PROPERTY externalName1;
      DROP PROPERTY externalName2;
  };
};
