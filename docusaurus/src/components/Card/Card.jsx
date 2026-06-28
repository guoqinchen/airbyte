import {
  faArrowRight,
  faBook,
  faCloud,
  faCode,
  faDownload,
  faGear,
  faLightbulb,
  faLock,
  faPlug,
  faPuzzlePiece,
  faRobot,
  faRocket,
  faWindowMaximize,
} from "@fortawesome/free-solid-svg-icons";
import { faPython } from "@fortawesome/free-brands-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { translate } from "@docusaurus/Translate";
import styles from "./Card.module.css";
import { CloudIcon, EnterpriseIcon, OssIcon } from "./CustomIcons";

const FA_ICONS = {
  "fa-book": faBook,
  "fa-cloud": faCloud,
  "fa-code": faCode,
  "fa-download": faDownload,
  "fa-gear": faGear,
  "fa-lightbulb": faLightbulb,
  "fa-lock": faLock,
  "fa-plug": faPlug,
  "fa-puzzle-piece": faPuzzlePiece,
  "fa-python": faPython,
  "fa-robot": faRobot,
  "fa-rocket": faRocket,
  "fa-window-maximize": faWindowMaximize,
};

const CUSTOM_ICONS = {
  cloud: CloudIcon,
  enterprise: EnterpriseIcon,
  oss: OssIcon,
};

const Link = ({ children, href, variant = "primary" }) => {
  const linkClass =
    variant === "secondary" ? styles.cardCtaSecondary : styles.cardCtaPrimary;

  return (
    <a className={`${styles.cardCta} ${linkClass}`} href={href}>
      {children}
      <FontAwesomeIcon icon={faArrowRight} />
    </a>
  );
};

const Icon = ({ name }) => {
  const IconComponent = FA_ICONS[name] || CUSTOM_ICONS[name];
  if (name in FA_ICONS) {
    return <FontAwesomeIcon icon={FA_ICONS[name]} />;
  }
  if (name in CUSTOM_ICONS) {
    return <IconComponent />;
  }
  return null;
};

/**
 * CardWithIcon renders an icon, title, description and optional CTA.
 * All visible text props (title, description, ctaText) are passed through
 * Docusaurus `translate()` so the same component renders the right locale
 * when invoked from MDX pages. Translation entries land in
 * `docusaurus/i18n/<locale>/code.json` under `card.<title|description|ctaText>`
 * (auto-derived from the source string by `pnpm write-translations`).
 */
export const CardWithIcon = ({
  title,
  description,
  ctaText,
  ctaLink,
  ctaVariant = "primary",
  icon,
}) => {
  const { message: translatedTitle } = translate({
    message: title,
    id: `card.title.${title}`,
  });
  const { message: translatedDescription } = translate({
    message: description,
    id: `card.description.${description}`,
  });
  const { message: translatedCtaText } = ctaText
    ? translate({ message: ctaText, id: `card.cta.${ctaText}` })
    : { message: ctaText };

  return (
    <div className={styles.card}>
      <div className={styles.cardContent}>
        {icon && (
          <div className={styles.cardIcon}>
            <Icon name={icon} />
          </div>
        )}
        <h2>{translatedTitle}</h2>
        <p>{translatedDescription}</p>
      </div>
      {translatedCtaText && (
        <Link href={ctaLink} variant={ctaVariant}>
          {translatedCtaText}
        </Link>
      )}
    </div>
  );
};
