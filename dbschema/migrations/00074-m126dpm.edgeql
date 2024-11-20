CREATE MIGRATION m126dpmwwunhiqgzro3vervqm7htib2zvlasdq3v357wu4x664c5ia
    ONTO m15mgxul2c75lix6ihwwdd3vjxmygmfaeqibw76khrendcujhoh44q
{
  ALTER TYPE default::Primitive {
      DROP PROPERTY estimatedTime;
  };
};
