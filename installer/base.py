from abc import ABC, abstractmethod


class Base(ABC):

    @property
    @abstractmethod
    def is_installed(self) -> bool:
        pass

    @abstractmethod
    def install(self) -> None:
        pass

    @abstractmethod
    def uninstall(self) -> None:
        pass
